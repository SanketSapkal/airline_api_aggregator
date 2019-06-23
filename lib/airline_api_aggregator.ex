defmodule AirlineAPIAggregator do
  @moduledoc """
  Documentation for AirlineAPIAggregator.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AirlineAPIAggregator.hello()
      :world

  """
  def hello do
    :world
  end

  def get_cheapest_flight(origin, destination, date) do
    #{data: {cheapestOffer: {amount: 55.19, airline: "BA"}}
    %{data:
      %{cheapestOffer: %{amount: 55.19, airline: "BA"}} 
    }
  end
end
