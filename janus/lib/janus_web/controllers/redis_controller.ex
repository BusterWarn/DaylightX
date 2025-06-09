defmodule JanusWeb.RedisController do
  use JanusWeb, :controller

  def check(conn, _params) do
    {:ok, redix_conn} = Redix.start_link(
      host: System.get_env("REDIS_HOST") || "localhost",
      port: String.to_integer(System.get_env("REDIS_PORT") || "6379"),
      password: System.get_env("REDIS_PASSWORD")
    )

    user = %{
      id: 123,
      name: "Alice",
      email: "alice@example.com",
      roles: ["admin", "editor"]
    }

    json = Jason.encode!(user)

    # Store the JSON string
    Redix.command!(redix_conn, ["SET", "user:123", json])

    # Retrieve it
    # Try to fetch the user JSON
    case Redix.command(redix_conn, ["GET", "user:123"]) do
      {:ok, nil} ->
        send_resp(conn, 404, "User not found")

      {:ok, json} ->
        user = Jason.decode!(json)
        json(conn, user)

      {:error, reason} ->
        send_resp(conn, 500, "Redis error: #{inspect(reason)}")
    end
  end
end
