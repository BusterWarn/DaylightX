defmodule JanusWeb.Router do
  use JanusWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", JanusWeb do
    pipe_through :api

    get "/health", HealthController, :check

    get "/location", LocationController, :timezone_get
    post "/location", LocationController, :timezone
  end
end
