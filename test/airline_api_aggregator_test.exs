defmodule AirlineAPIAggregatorTest do
  use ExUnit.Case
  use Plug.Test

  alias AirlineAPIAggregator.Router

  doctest AirlineAPIAggregator

  @router_opts Router.init([])
  @origin "BER"
  @destination "LHR"
  @date "2019-07-17"

  test "success on getting cheapest ticket" do
    conn =
      :get
      |> conn("/findCheapestOffer?origin=#{@origin}&destination=#{@destination}&departureDate=#{@date}")
      |> Router.call(@router_opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "returns 404" do
    conn =
      :get
      |> conn("/someAPI", "")
      |> Router.call(@router_opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

  # TODO: Add test case to check polymorphism.

  # TODO: Add test case to check rate limiter.

  # TODO: Add test case for cheapest ticket when the xml data is taken from disk rather than rest api.
  
end
