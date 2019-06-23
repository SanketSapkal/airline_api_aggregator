defmodule AirlineAPIAggregator.AFKL do

  import SweetXml

  @behaviour AirlineAPIAggregator.APIBehaviour

  @airline_code "AFKL"

  def get_cheapest_offer(origin, destination, date) do
    Application.get_env(:airline_api_aggregator, :afkl)[:body]
    |> AirlineAPIAggregator.prepare_body(origin, destination, date)
    |> get_data
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

  defp get_data(body) do
    url = Application.get_env(:airline_api_aggregator, :afkl)[:url]
    headers = Application.get_env(:airline_api_aggregator, :afkl)[:headers]

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{body: xml, status_code: 200}} ->
        parse_xml_and_get_cheapest_offer(xml)
      {:ok, %HTTPoison.Response{status_code: other_status_code}} ->
        IO.puts("Failed with status_code: #{other_status_code}")
        {:error, "Failed with status_code: #{other_status_code}"}
      {:error, reason} ->
        IO.puts("Failed with reason: #{reason}")
        {:error, reason}
    end
  end
end
