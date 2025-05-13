#!/bin/bash

# Check if URL argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <URL>"
  echo "Example: $0 \"http://lunak-service:8080/\""
  exit 1
fi

URL="$1"

# Get the janus pod name
JANUS_POD=$(kubectl get pods | grep janus | grep Running | head -1 | awk '{print $1}')

if [ -z "$JANUS_POD" ]; then
  echo "Error: Could not find running janus pod"
  exit 1
fi

echo "Using janus pod: $JANUS_POD"
echo "Making request to: $URL"
echo "---"

# Create a temporary Elixir script that properly initializes the application
ELIXIR_SCRIPT='
url = System.argv() |> List.first()

# Start the necessary applications
Application.ensure_all_started(:ssl)
Application.ensure_all_started(:hackney)
Application.ensure_all_started(:httpoison)

case HTTPoison.get(url) do
  {:ok, %HTTPoison.Response{status_code: status, body: body, headers: headers}} ->
    IO.puts("Status: #{status}")
    IO.puts("Headers:")
    Enum.each(headers, fn {k, v} -> IO.puts("  #{k}: #{v}") end)
    IO.puts("\nBody:")
    # Try to pretty print JSON if possible
    case Jason.decode(body) do
      {:ok, json} ->
        Jason.encode!(json, pretty: true) |> IO.puts()
      {:error, _} ->
        IO.puts(body)
    end
  {:error, reason} ->
    IO.puts("Error: #{inspect(reason)}")
end
'

# Execute using rpc.call to the running node which has all applications loaded
kubectl exec -it "$JANUS_POD" -- bin/janus rpc "
url = \"$URL\"
case HTTPoison.get(url) do
  {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
    IO.puts(\"Status: #{status}\")
    IO.puts(\"\\nBody:\")
    IO.puts(body)
  {:error, reason} ->
    IO.puts(\"Error: #{inspect(reason)}\")
end
"
