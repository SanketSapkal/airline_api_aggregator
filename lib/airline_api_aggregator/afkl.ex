defmodule AirlineAPIAggregator.AFKL do

  import SweetXml

  @behaviour AirlineAPIAggregator.APIBehaviour

  @airline_code "AFKL"

  def get_cheapest_offer(origin, destination, date, :web) do
    {@airline_code, 56.19}
  end

  def parse_xml_and_get_cheapest_offer(xml) do
    cheapest_ticket =
      xml
      |> xpath(~x"//AirlineOffers/Offer/TotalPrice/DetailCurrencyPrice/Total/text()"l)
      |> Enum.map(fn price ->
        price |> to_string |> String.to_float
      end)
      |> Enum.min

    {@airline_code, cheapest_ticket}
  end
end
