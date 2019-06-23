defmodule AirlineAPIAggregator do
  @moduledoc """
  Documentation for AirlineAPIAggregator.
  """

  use GenServer

  alias AirlineAPIAggregator.AFKL
  alias AirlineAPIAggregator.BA
  alias AirlineAPIAggregator.RateLimiter

  @airline_modules [BA, AFKL]
  @origin_default "ORIGIN_AIRPORT"
  @destination_default "DESTINATION_AIRPORT"
  @date_default "TRAVEL_DATE"
  @default_timeout :timer.minutes(5)
  @genserver_name :airline_api_aggregator

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: @genserver_name)
  end

  def init(state) do
    # Send first reset from here or the start the reseting process.
    reset_rate_limiter()
    {:ok, state}
  end

  def get_cheapest_flight(origin, destination, date) do
    GenServer.call(@genserver_name, {:get_cheapest_flight, {origin, destination, date}})
  end

  @doc """
  Hello world.

  ## Examples

      iex> AirlineAPIAggregator.hello()
      :world

  """
  def hello do
    :world
  end

  def reset_rate_limiter() do
    reset_seconds_rate_limiter()
    reset_daily_rate_limiter()
  end

  def prepare_body(body, origin, destination, date) do
    #IO.puts("Arguments received: #{body}, #{origin}, #{destination}, #{date}")
    body
    |> String.replace(@origin_default, origin)
    |> String.replace(@destination_default, destination)
    |> String.replace(@date_default, date)
  end

  def handle_call({:get_cheapest_flight, {origin, destination, date}}, _from, state) do
    reply =
      case RateLimiter.token_available? do
        true ->
          @airline_modules
          |> Enum.map(
            &Task.async(fn -> &1.get_cheapest_offer(origin, destination, date) end)
          )
          |> Enum.map(fn task -> Task.await(task, @default_timeout) end)
          |> Enum.filter(fn {airline_code, _ticket_price} -> airline_code != :error end)
          |> get_min

        false ->
          {:error, "No tokens available, please try again later"}
      end

    reply = reply |> response_format()

    {:reply, reply, state}
  end

  def handle_info(:reset_tokens_in_second, state) do
    RateLimiter.reset_tokens_in_second()
    reset_seconds_rate_limiter()
    {:noreply, state}
  end

  def handle_info(:reset_daily_tokens, state) do
    RateLimiter.reset_daily_tokens()
    reset_daily_rate_limiter()
    {:noreply, state}
  end

  defp reset_seconds_rate_limiter() do
    Process.send_after(self(), :reset_tokens_in_second, :timer.seconds(1000))
  end

  defp reset_daily_rate_limiter() do
    Process.send_after(self(), :reset_daily_tokens, :timer.seconds(1000))
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
