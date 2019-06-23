defmodule AirlineAPIAggregator do
  @moduledoc """
  Documentation for AirlineAPIAggregator.
  """

  alias AirlineAPIAggregator.AFKL
  alias AirlineAPIAggregator.BA

  @airline_modules [BA, AFKL]
  @origin_default "ORIGIN_AIRPORT"
  @destination_default "DESTINATION_AIRPORT"
  @date_default "TRAVEL_DATE"
  @default_timeout :timer.minutes(5)

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
    #IO.puts("#{origin}, #{destination}, #{date}")
    @airline_modules
    |> Enum.map(
      &Task.async(fn -> &1.get_cheapest_offer(origin, destination, date) end)
    )
    |> Enum.map(fn task -> Task.await(task, @default_timeout) end)
    |> Enum.filter(fn {airline_code, _ticket_price} -> airline_code != :error end)
    |> get_min
    |> response_format()
  end

  def prepare_body(body, origin, destination, date) do
    #IO.puts("Arguments received: #{body}, #{origin}, #{destination}, #{date}")
    body
    |> String.replace(@origin_default, origin)
    |> String.replace(@destination_default, destination)
    |> String.replace(@date_default, date)
  end

  defp get_min([]) do
    {:error, "No flights found."}
  end

  defp get_min(result_list) do
    result_list |> Enum.min_by(fn {_airline_code, ticket_price} -> ticket_price end)
  end

  defp response_format({:error, reason}) do
    %{
      data: %{error: reason}
    }
  end

  defp response_format({airline_code, ticket_price}) do
    %{
      data: %{cheapestOffer: %{amount: ticket_price, airline: airline_code}}
    }
  end
end
