defmodule JanusWeb.HealthController do
  use JanusWeb, :controller

  def check(conn, _params) do
    json(conn, %{status: "ok", service: "janus"})
  end
end
