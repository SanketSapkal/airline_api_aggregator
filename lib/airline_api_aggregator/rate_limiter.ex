defmodule AirlineAPIAggregator.RateLimiter do
  @moduledoc """
  Token based rate limiter implemented using Elixir Agent. Has functions for
  getting a token and resetting the tokens available.

  This rate limiter is been used as the error provided and the behaviour of
  airline api after request limit exhaustion is unknown.
  """
  use Agent

  @tokens_per_day Application.get_env(:airline_api_aggregator, :rate_limiter)[:tokens_per_day]
  @token_per_second Application.get_env(:airline_api_aggregator, :rate_limiter)[:tokens_per_second]

  def start_link(_) do
    Agent.start_link(fn -> {@tokens_per_day, @token_per_second} end, name: __MODULE__)
  end

  def token_available?() do
    Agent.get(__MODULE__, fn {daily_token, token_in_second} -> {daily_token, token_in_second} end)
    |> decrement_tokens
  end

  @doc """
  Reset the tokens, to initial count.
  ## Examples:
      :iex> AirlineAPIAggregator.RateLimiter.reset_tokens()
      :ok
  """
  @spec reset_daily_tokens() :: :ok
  def reset_daily_tokens() do
    Agent.update(__MODULE__, fn _state -> {@tokens_per_day, @token_per_second} end)
  end

  @spec reset_tokens_in_second() :: :ok
  def reset_tokens_in_second() do
    IO.puts("Resetting tokens")
    Agent.update(__MODULE__, fn {daily_token, token_in_second} ->
      cond do
        daily_token >= (@token_per_second - token_in_second) -> {daily_token - (@token_per_second - token_in_second), @token_per_second}
        daily_token < (@token_per_second - token_in_second) and daily_token > 0 -> {0, daily_token}
        true -> {0, 0}
      end
    end)
  end

  #
  # No operation is done here and false is returned as tokens are not available.
  #
  defp decrement_tokens({_daily_token, token_in_second}) when token_in_second <= 0 do
    false
  end

  #
  # Decrement the token count by 1 and return true. Here true signifies a token
  # can be given to the calling process.
  #
  defp decrement_tokens({_daily_token, _token_in_second}) do
    Agent.update(__MODULE__, fn {daily_token, token_in_second} -> {daily_token, token_in_second - 1} end)
    true
  end
end
