defmodule JanusWeb.LocationController do
  use JanusWeb, :controller

  # Service URLs
  @bunpass_service_url "http://bunpass-service:3000"
  @delorean_service_url "http://delorean-service:8000"
  @arvaker_service_url "http://arvaker-service:8080"
  @lunak_service_url "http://lunak-service:8080"

  # Handle POST request with location string
  def location_data(conn, %{"location" => location}) when is_binary(location) do
    with {:ok, location_data} <- get_coordinates_from_bunpass(location),
         {:ok, %{lat: lat, lon: lon}} <- extract_and_parse_coordinates(location_data),
         {:ok, timezone_data} <- get_timezone_from_delorean(lat, lon),
         {:ok, sun_data} <- get_sun_data_from_arvaker(),
         {:ok, moon_data} <- get_moon_data_from_lunak(lat, lon) do
      # Success: return combined data
      response =
        location_data
        |> Map.merge(timezone_data)
        |> Map.put("sun_data", sun_data)
        |> Map.put("moon_data", moon_data)

      json(conn, response)
    else
      {:error, :missing_coordinates} ->
        send_error(conn, :bad_request, "Invalid coordinates received from location service")

      {:error, :invalid_coordinates} ->
        send_error(conn, :bad_request, "Invalid coordinates format")

      {:error, {:bunpass, reason}} ->
        send_error(conn, :service_unavailable, "Failed to get location data: #{reason}")

      {:error, {:delorean, reason}} ->
        send_error(conn, :service_unavailable, "Failed to get timezone: #{reason}")

      {:error, {:arvaker, reason}} ->
        send_error(conn, :service_unavailable, "Failed to get sun data: #{reason}")

      {:error, {:lunak, reason}} ->
        send_error(conn, :service_unavailable, "Failed to get moon data: #{reason}")
    end
  end

  # Handle missing parameters
  def location_data(conn, _params) do
    send_error(conn, :bad_request, "Missing required parameter: location")
  end

  # Extract and parse coordinates from location data
  defp extract_and_parse_coordinates(%{"lat" => lat, "lon" => lon}) do
    with {:ok, latitude} <- parse_float(lat),
         {:ok, longitude} <- parse_float(lon) do
      {:ok, %{lat: latitude, lon: longitude}}
    else
      _ -> {:error, :invalid_coordinates}
    end
  end

  defp extract_and_parse_coordinates(_), do: {:error, :missing_coordinates}

  # Get coordinates from bunpass service
  defp get_coordinates_from_bunpass(location) do
    encoded_location = URI.encode_www_form(location)
    url = "#{@bunpass_service_url}/location?place=#{encoded_location}"

    url
    |> make_http_get_request()
    |> handle_service_response(:bunpass)
  end

  # Get timezone from delorean service
  defp get_timezone_from_delorean(lat, lon) do
    url = "#{@delorean_service_url}/timezone?lat=#{lat}&lon=#{lon}"

    url
    |> make_http_get_request()
    |> handle_service_response(:delorean)
  end

  # Make HTTP request with timeout
  defp make_http_get_request(url) do
    HTTPoison.get(url, [], timeout: 5_000, recv_timeout: 5_000)
  end

  # Handle service response uniformly
  defp handle_service_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, _service) do
    case Jason.decode(body) do
      {:ok, data} -> {:ok, data}
      {:error, _} -> {:error, :json_decode_error}
    end
  end

  defp handle_service_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}}, service) do
    error_message =
      case Jason.decode(body) do
        {:ok, %{"error" => error}} -> error
        _ -> "Service returned status: #{status_code}"
      end

    {:error, {service, error_message}}
  end

  defp handle_service_response({:error, %HTTPoison.Error{reason: reason}}, service) do
    {:error, {service, "Connection failed: #{reason}"}}
  end

  # Parse float values
  defp parse_float(value) when is_binary(value) do
    case Float.parse(value) do
      {float, ""} -> {:ok, float}
      _ -> {:error, :invalid}
    end
  end

  defp parse_float(value) when is_number(value), do: {:ok, value}
  defp parse_float(_), do: {:error, :invalid}

  # Get sun data from arvaker service
  defp get_sun_data_from_arvaker() do
    {:ok, "sun is fun"}
    #  TODO: Fix when arvaker works
    # @arvaker_service_url
    # |> make_http_get_request()
    # |> handle_service_response(:arvaker)
  end

  # Get moon data from lunak service
  defp get_moon_data_from_lunak(lat, lon) do
    # Get current time in ISO8601 format
    time = DateTime.utc_now() |> DateTime.to_iso8601()
    url = "#{@lunak_service_url}/moon?latitude=#{lat}&longitude=#{lon}&time=#{time}"

    url
    |> make_http_get_request()
    |> handle_service_response(:lunak)
  end

  # Centralized error response
  defp send_error(conn, status, message) do
    conn
    |> put_status(status)
    |> json(%{error: message})
  end
end
