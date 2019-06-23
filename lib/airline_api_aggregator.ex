defmodule AirlineAPIAggregator do
  @moduledoc """
  Airline API Aggregator which helps the user to find cheapest flights among the
  connected airlines.

  It built using genserver for supervision, agent for rate limiting at the app side
  and behaviour which makes it easy to integrate multiple airlines apis.

  The ArilineAPIAggregator module also resets the daily tokens (max daily requests)
  and the tokens per second(max requests per second).

  The cheapest flights across the connected airlines are concurrently being get
  and the cheapest among them is returned to the user.
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
    # Send first reset(both daily tokens and per second tokens) from here or the
    # start the reseting process.
    reset_rate_limiter()
    {:ok, state}
  end

  @doc """
  Get cheapest flight among all the connected airlines.

  ## Parameters accepted:
  - origin: the airport code from where the flight departs.
  - destination: the code where the flight lands, i.e. destination airport code.
  - date: Date of travel. Format: "yyyy-mm-dd" in string.

  Makes a synchronous call to the :airline_api_aggregator genserver.

  ## Examples:
      To get the cheapest flight from Berlin to London on 29th June 2019:

      :iex> AirlineAPIAggregator.get_cheapest_flight("BER", "LHR", "2019-06-29")
  """
  @spec get_cheapest_flight(String.t, String.t, String.t) :: map()
  def get_cheapest_flight(origin, destination, date) do
    GenServer.call(@genserver_name, {:get_cheapest_flight, {origin, destination, date}}, @default_timeout)
  end

  @doc """
  Prepare the body of the external API to be called via HTTPoison.
  The config contains the basic skeleten for connected airline api, the body
  contains the origin, destination, date information.
  Default strings: @origin_default, @destination_default, @date_default which are
  already in the body are replaced with the values provided by the user.

  ## Parameters accepted:
  - body: XML of the body(payload) expected by the airline api.
  - origin: the airport code from where the flight departs.
  - destination: the code where the flight lands, i.e. destination airport code.
  - date: Date of travel. Format: "yyyy-mm-dd" in string.

  ## Examples:
      :iex> body_xml = Application.get_env(:airline_api_aggregator, :ba)[:body]
      :iex> AirlineAPIAggregator.prepare_body(body_xml, "BER", "LHR", "2019-06-29")
  """
  @spec prepare_body(String.t, String.t, String.t, String.t) :: String.t
  def prepare_body(body, origin, destination, date) do
    #Replace the defaults with actual data provided by the user.
    body
    |> String.replace(@origin_default, origin)
    |> String.replace(@destination_default, destination)
    |> String.replace(@date_default, date)
  end

  #
  # Received a message to get the cheapest flight from the origin airport to
  # destination airport on the specified date. The cheapest flights of all
  # connected airlines are compared, and the cheapest among them is returned to
  # the user
  #
  def handle_call({:get_cheapest_flight, {origin, destination, date}}, _from, state) do
    reply =
      case RateLimiter.token_available? do
        true ->
          # Token is available
          @airline_modules
          |> Enum.map(
            &Task.async(fn -> &1.get_cheapest_offer(origin, destination, date) end)
          )
          |> Enum.map(fn task -> Task.await(task, @default_timeout) end)
          # Filter the error messages
          |> Enum.filter(fn {airline_code, _ticket_price} -> airline_code != :error end)
          |> get_min

        false ->
          # Token is not available
          {:error, "No tokens available, please try again later"}
      end

    reply = reply |> response_format()
    {:reply, reply, state}
  end

  #
  # Received messgae to reset the per second tokens, calls the rate limiter to
  # reset the per second tokens.
  #
  def handle_info(:reset_tokens_in_second, state) do
    RateLimiter.reset_tokens_in_second()
    reset_seconds_rate_limiter()
    {:noreply, state}
  end

  #
  # Received messgae to reset the daily tokens, calls the rate limiter to
  # reset the daily tokens.
  #
  def handle_info(:reset_daily_tokens, state) do
    RateLimiter.reset_daily_tokens()
    reset_daily_rate_limiter()
    {:noreply, state}
  end

  #
  # Starts the reset token mechanism for both daily tokens as well as per second
  # tokens.
  #
  defp reset_rate_limiter() do
    reset_seconds_rate_limiter()
    reset_daily_rate_limiter()
  end

  #
  # Token reset mechanism for per second tokens, sends a message to self process
  # after one second.
  #
  defp reset_seconds_rate_limiter() do
    Process.send_after(self(), :reset_tokens_in_second, :timer.seconds(1))
  end

  #
  # Token reset mechanism for daily tokens, sends a message to self process
  # after 24 hours.
  #
  defp reset_daily_rate_limiter() do
    Process.send_after(self(), :reset_daily_tokens, :timer.hours(24))
  end

  #
  # Result list after filtering errors is empty, this signifies that all the calls
  # to connected airlines resulted in failure. Error is returned to user.
  #
  defp get_min([]) do
    {:error, "No flights found."}
  end

  #
  # Find the airline with cheapest flight ticket.
  # result_list: [{airline_code :: String.t, ticket_price :: integer}]
  #
  defp get_min(result_list) do
    result_list |> Enum.min_by(fn {_airline_code, ticket_price} -> ticket_price end)
  end

  #
  # Convert the response to map, which is later on converted to json.
  # Error case.
  #
  defp response_format({:error, reason}) do
    %{
      data: %{error: reason}
    }
  end

  #
  # Convert the response to map, which is later on converted to json.
  # Success case.
  #
  defp response_format({airline_code, ticket_price}) do
    %{
      data: %{cheapestOffer: %{amount: ticket_price, airline: airline_code}}
    }
  end
end
