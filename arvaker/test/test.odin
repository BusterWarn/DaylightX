package test

import "core:fmt"
import "core:testing"

import main "../src"

@(test)
parse_request_query__should_parse_valid_query :: proc(t: ^testing.T) {
	query, ok := main.parse_request_query(
		"latitude=63.8258&longitude=20.2630&date=2025-03-26&offset=+01:00",
	).(main.Query)
	testing.expect(t, ok, "Expected to return a Query struct")
}

@(test)
build_request_url__should_build_valid_request_url :: proc(t: ^testing.T) {
	query :: main.Query {
		longitude = "11",
		latitude  = "22",
		date      = "33",
		offset    = "44",
	}

	actual_url := main.build_request_url(query)
	defer delete(actual_url)
	expected_url :: "https://api.met.no/weatherapi/sunrise/3.0/sun?lat=22&lon=11&date=33&offset=44"

	testing.expect(t, actual_url == expected_url, "Expected a valid ulr")
}
