defmodule AirlineAPIAggregatorTest do
  use ExUnit.Case
  use Plug.Test

  alias AirlineAPIAggregator.Router

  doctest AirlineAPIAggregator

  @router_opts Router.init([])
  @origin "BER"
  @destination "LHR"
  @date "2019-07-17"

  @ba_code "BA"
  @afkl_code "AFKL"
  @ba_xml "./priv/sample_xml/BA.xml"
  @afkl_xml "./priv/sample_xml/AFKL.xml"

  test "success status code on getting cheapest ticket" do
    conn =
      :get
      |> conn("/findCheapestOffer?origin=#{@origin}&destination=#{@destination}&departureDate=#{@date}")
      |> Router.call(@router_opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "returns 404 when a non supported api is called" do
    conn =
      :get
      |> conn("/someAPI", "")
      |> Router.call(@router_opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

  test "xml parsing for BA" do
    # 77.14 is the min ticket value in BA.xml
    expected_result = {@ba_code, 77.14}

    actual_result =
      @ba_xml |> File.read! |> AirlineAPIAggregator.BA.parse_xml_and_get_cheapest_offer

    assert expected_result == actual_result
  end

  test "xml parsing for AFKL" do
    # 509.11 is the min ticket value in AFKL.xml
    expected_result = {@afkl_code, 509.11}

    actual_result =
      @afkl_xml |> File.read! |> AirlineAPIAggregator.AFKL.parse_xml_and_get_cheapest_offer

    assert expected_result == actual_result
  end
end
