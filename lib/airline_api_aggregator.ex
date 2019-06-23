defmodule AirlineAPIAggregator do
  @moduledoc """
  Documentation for AirlineAPIAggregator.
  """

  alias AirlineAPIAggregator.AFKL
  alias AirlineAPIAggregator.BA

  @airline_modules [BA, AFKL]

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
    @airline_modules
    |> Enum.map(
      &Task.async(fn -> &1.get_cheapest_offer(origin, destination, date) end)
    )
    |> Enum.map(fn task -> Task.await(task) end)
    |> Enum.min_by(fn {_airline_code, ticket_price} -> ticket_price end)
    |> response_format()
  end

  defp response_format({airline_code, ticket_price}) do
    %{
      data: %{cheapestOffer: %{amount: ticket_price, airline: airline_code}}
    }
  end
end
