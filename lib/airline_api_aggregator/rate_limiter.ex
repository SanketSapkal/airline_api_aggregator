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

  @doc """
  Get a token from rate limiter if available. The tokens are get first,
    - tokens are available(or num of tokens > 0): return true to the calling process, decrement the token count.
    - no tokens are available: return false to the calling process.

  Here the tokens per second are being checked for.

  ## Examples:
      :iex> TwitterScrapper.RateLimiter.token_available?()
      true
  """
  @spec token_available?() :: boolean
  def token_available?() do
    Agent.get(__MODULE__, fn {daily_token, token_in_second} -> {daily_token, token_in_second} end)
    |> decrement_tokens
  end

  @doc """
  Reset the daily tokens, to initial count.
  ## Examples:
      :iex> AirlineAPIAggregator.RateLimiter.reset_daily_tokens()
      :ok
  """
  @spec reset_daily_tokens() :: :ok
  def reset_daily_tokens() do
    Agent.update(__MODULE__, fn _state -> {@tokens_per_day, @token_per_second} end)
  end

  @doc """
  Reset the per second tokens, to initial count.
  ## Examples:
      :iex> AirlineAPIAggregator.RateLimiter.reset_tokens_in_second()
      :ok
  """
  @spec reset_tokens_in_second() :: :ok
  def reset_tokens_in_second() do
    Agent.update(__MODULE__, fn {daily_token, token_in_second} ->
      cond do
        daily_token >= (@token_per_second - token_in_second) ->
          # All the used tokens can be refreshed here, as the daily tokens are high.
          # (high is >= used tokens)
          {daily_token - (@token_per_second - token_in_second), @token_per_second}

        daily_token < (@token_per_second - token_in_second) and daily_token > 0 ->
          # All the used tokens cannot be refreshed, as the daily tokens are low.
          # (low is < used tokens)
          {0, daily_token}

        true ->
          # No daily tokens available to refresh the used tokens.
          {0, 0}
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
