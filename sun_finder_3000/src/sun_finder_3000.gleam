import argv
import gleam/bytes_tree.{type BytesTree}
import gleam/hackney
import gleam/http/elli
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/io
import gleam/result
import gleeunit/should

fn get_sun_from_weatherapi() -> Result(String, hackney.Error) {
  let assert Ok(sun_request) =
    request.to(
      "https://api.met.no/weatherapi/sunrise/3.0/moon?lat=63.8258&lon=20.2630&date=2025-03-26&offset=+01:00",
    )

  // Send the HTTP request to the server
  use sun_response <- result.try(
    sun_request
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")
    |> hackney.send,
  )

  // We get a response record back
  sun_response.status
  |> should.equal(200)

  sun_response
  |> response.get_header("content-type")
  |> should.equal(Ok("application/json"))

  Ok(sun_response.body)
}

fn sun_finder_service(_request: Request(t)) -> Response(BytesTree) {
  let return_data = case get_sun_from_weatherapi() {
    Ok(sun_json) -> sun_json
    Error(_) -> "Failure"
  }

  let body = bytes_tree.from_string(return_data)

  response.new(200)
  |> response.prepend_header("made-with", "Gleam")
  |> response.set_body(body)
}

fn start_service(port: String) {
  case int.parse(port) {
    Ok(port) ->
      case elli.become(sun_finder_service, on_port: port) {
        Ok(_) -> io.println("Server shut down")
        Error(_) -> io.println("Server shut down unexpectedly")
      }
    Error(_) -> print_usage()
  }
}

fn print_usage() {
  io.println("usage: gleam run port <port>")
}

pub fn main() {
  case argv.load().arguments {
    ["port", port] -> start_service(port)
    _ -> print_usage()
  }
}
