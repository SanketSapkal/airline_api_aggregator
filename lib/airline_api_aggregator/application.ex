defmodule AirlineAPIAggregator.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: AirlineAPIAggregator.Router, options: [port: 4000]),
      {AirlineAPIAggregator, []},
      {AirlineAPIAggregator.RateLimiter, []}
    ]

    opts = [strategy: :one_for_one, name: AirlineAPIAggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
