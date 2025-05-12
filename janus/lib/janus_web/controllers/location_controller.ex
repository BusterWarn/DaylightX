defmodule JanusWeb.LocationController do
  use JanusWeb, :controller

  # Service URLs
  @bunpass_service_url "http://bunpass-service:3000"
  @delorean_service_url "http://delorean-service:8000"

  # Handle POST request with location string
  def timezone(conn, %{"location" => location}) when is_binary(location) do
    # First, get coordinates from bunpass service
    case get_coordinates_from_bunpass(location) do
      {:ok, %{"lat" => lat, "lon" => lon} = location_data} ->
        # Convert string lat/lon to floats
        case {parse_float(lat), parse_float(lon)} do
          {{:ok, latitude}, {:ok, longitude}} ->
            # Get timezone data from delorean
            case get_timezone_from_delorean(latitude, longitude) do
              {:ok, timezone_data} ->
                # Return combined data (location info + timezone)
                response = Map.merge(location_data, timezone_data)
                json(conn, response)

              {:error, reason} ->
                conn
                |> put_status(:service_unavailable)
                |> json(%{error: "Failed to get timezone: #{reason}"})
            end

          _ ->
            conn
            |> put_status(:bad_request)
            |> json(%{error: "Invalid coordinates received from location service"})
        end

      {:error, reason} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "Failed to get location data: #{reason}"})
    end
  end

  # Handle missing parameters
  def timezone(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing required parameter: location"})
  end

  defp get_coordinates_from_bunpass(location) do
    # Use GET request with 'place' query parameter
    encoded_location = URI.encode_www_form(location)
    url = "#{@bunpass_service_url}/location?place=#{encoded_location}"

    case HTTPoison.get(url, [], timeout: 5_000, recv_timeout: 5_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, data} -> {:ok, data}
          {:error, _} -> {:error, "Failed to parse bunpass response"}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
        error_message =
          case Jason.decode(response_body) do
            {:ok, %{"error" => error}} -> error
            _ -> "Bunpass service returned status: #{status_code}"
          end

        {:error, error_message}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to connect to bunpass service: #{reason}"}
    end
  end

  defp get_timezone_from_delorean(lat, lon) do
    # Construct the URL with query parameters
    url = "#{@delorean_service_url}/timezone?lat=#{lat}&lon=#{lon}"

    case HTTPoison.get(url, [], timeout: 5_000, recv_timeout: 5_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} -> {:ok, data}
          {:error, _} -> {:error, "Failed to parse delorean response"}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        error_message =
          case Jason.decode(body) do
            {:ok, %{"error" => error}} -> error
            _ -> "Delorean service returned status: #{status_code}"
          end

        {:error, error_message}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to connect to delorean service: #{reason}"}
    end
  end

  defp parse_float(value) when is_binary(value) do
    case Float.parse(value) do
      {float, ""} -> {:ok, float}
      _ -> {:error, :invalid}
    end
  end

  defp parse_float(value) when is_number(value), do: {:ok, value}
  defp parse_float(_), do: {:error, :invalid}
end
