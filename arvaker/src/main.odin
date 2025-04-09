package main

import "core:fmt"
import "core:log"

import http "../lib/odin-http/"
import "../lib/odin-http/client"

main :: proc() {
	context.logger = log.create_console_logger(.Debug)

	server: http.Server

	handler := http.handler(handle_request)
	http.server_shutdown_on_interrupt(&server)

	fmt.printf("Server stopped: %s", http.listen_and_serve(&server, handler))
}

handle_request :: proc(request: ^http.Request, res: ^http.Response) {
	fmt.println(request.url.query)
	sun_data := get()
	switch v in sun_data {
	case string:
		{
			res.status = .OK
			http.body_set_str(res, sun_data.(string))
			http.respond(res)
		}
	}
}

get :: proc() -> Maybe(string) {
	res, err := client.get(
		"https://api.met.no/weatherapi/sunrise/3.0/sun?lat=63.8258&lon=20.2630&date=2025-03-26&offset=+01:00",
	)
	if err != nil {
		fmt.printf("Request failed: %s", err)
		return nil
	}
	defer client.response_destroy(&res)

	// fmt.printf("Status: %s\n", res.status)
	// fmt.printf("Headers: %v\n", res.headers)
	// fmt.printf("Cookies: %v\n", res.cookies)
	body, allocation, berr := client.response_body(&res)
	if berr != nil {
		fmt.printf("Error retrieving response body: %s", berr)
		return nil
	}
	defer client.body_destroy(body, allocation)

	fmt.println(body)

	if i, ok := body.(client.Body_Plain); ok {
		return i
	}

	return nil
}
