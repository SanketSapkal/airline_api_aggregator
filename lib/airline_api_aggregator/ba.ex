defmodule AirlineAPIAggregator.BA do

  import SweetXml

  @behaviour AirlineAPIAggregator.APIBehaviour

  @airline_code "BA"

  def get_cheapest_offer(origin, destination, date) do
    {@airline_code, 55.19}
  end

  def parse_xml_and_get_cheapest_offer(xml) do
    cheapest_ticket =
      xml
      |> xpath(~x"//AirlineOffers/AirlineOffer/TotalPrice/SimpleCurrencyPrice/text()"l)
      |> Enum.map(fn price ->
        price |> to_string |> String.to_float
      end)
      |> Enum.min

    {@airline_code, cheapest_ticket}
  end

end
