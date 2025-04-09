package main

import "core:log"
import "core:strings"

import http "../lib/odin-http/"
import "../lib/odin-http/client"

main :: proc() {
	context.logger = log.create_console_logger(.Debug)

	server: http.Server

	handler := http.handler(handle_client_request)
	http.server_shutdown_on_interrupt(&server)

	log.info("Server stopped: %s", http.listen_and_serve(&server, handler))
}

Query :: struct {
	longitude: string,
	latitude:  string,
	date:      string,
	offset:    string,
}

ParseError :: enum {
	NoQuery,
	MalformedQuery,
	IncorrectNumberOfSubQueries,
	MissingArgument,
}

ParseResult :: union {
	Query,
	ParseError,
}

parse_request_query :: proc(query: string) -> ParseResult {
	if len(query) == 0 {
		log.warn("Got no query")
		return ParseError.NoQuery
	}

	sub_queries, query_err := strings.split(query, "&")
	defer delete(sub_queries)
	if query_err != nil {
		log.warn("Got malformed query", query)
		return ParseError.MalformedQuery
	}

	expected_number_of_sub_queries :: 4
	if len(sub_queries) != expected_number_of_sub_queries {
		log.warn(
			"Got incorrect number of sub queries, expected",
			expected_number_of_sub_queries,
			", got",
			len(sub_queries),
		)
		return ParseError.MalformedQuery
	}

	query := Query {
		longitude = "",
		latitude  = "",
		date      = "",
		offset    = "",
	}

	for sub_query in sub_queries {
		sub_sub_query, query_err := strings.split(sub_query, "=")
		defer delete(sub_sub_query)
		if query_err != nil || len(sub_sub_query) != 2 {
			log.warn("Got malformed query", sub_query)
			return ParseError.MalformedQuery
		}

		if sub_sub_query[0] == "longitude" {
			query.longitude = sub_sub_query[1]
		} else if sub_sub_query[0] == "latitude" {
			query.latitude = sub_sub_query[1]
		} else if sub_sub_query[0] == "date" {
			query.date = sub_sub_query[1]
		} else if sub_sub_query[0] == "offset" {
			query.offset = sub_sub_query[1]
		}
	}

	if query.longitude == "" || query.latitude == "" || query.date == "" || query.offset == "" {
		return ParseError.MissingArgument
	}

	return query
}

handle_client_request :: proc(request: ^http.Request, response: ^http.Response) {
	query := parse_request_query(request.url.query[:])

	switch q in query {
	case ParseError:
		{
			response.status = .Bad_Request
			http.respond(response)
			return
		}
	case Query:
		handle_client_query(q, response)
	}
}

handle_client_query :: proc(query: Query, response: ^http.Response) {
	sun_data := get_sun_data(query)
	switch v in sun_data {
	case string:
		{
			response.status = .OK
			http.body_set_str(response, sun_data.(string))
			http.respond(response)
		}
	}
}

build_request_url :: proc(query: Query) -> string {
	parts := [?]string {
		"https://api.met.no/weatherapi/sunrise/3.0/sun?",
		"lat=",
		query.latitude,
		"&lon=",
		query.longitude,
		"&date=",
		query.date,
		"&offset=",
		query.offset,
	}
	return strings.concatenate(parts[:])
}

get_sun_data :: proc(query: Query) -> Maybe(string) {
	request_url := build_request_url(query)
	defer delete(request_url)

	res, err := client.get(request_url)
	if err != nil {
		log.error("Request failed: %s", err)
		return nil
	}
	defer client.response_destroy(&res)

	body, allocation, berr := client.response_body(&res)
	if berr != nil {
		log.error("Error retrieving response body: %s", berr)
		return nil
	}
	defer client.body_destroy(body, allocation)

	log.debug(body)

	if i, ok := body.(client.Body_Plain); ok {
		return i
	}

	return nil
}
