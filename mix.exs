defmodule AirlineAPIAggregator.MixProject do
  use Mix.Project

  def project do
    [
      app: :airline_api_aggregator,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AirlineAPIAggregator.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.0"},
      {:sweet_xml, "~> 0.6.5"},
      {:httpoison, "~> 1.4"}
    ]
  end
end
