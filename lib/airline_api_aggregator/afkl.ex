defmodule AirlineAPIAggregator.AFKL do
  @moduledoc """
  AFKL airlines aggregator module. Fetches data from airlines. Currently fetches
  the flight data for a origin airport to destination airport on the specified
  date.
  """

  import SweetXml

  @behaviour AirlineAPIAggregator.APIBehaviour

  @airline_code "AFKL"

  @doc """
  Get the direct cheapest flight(from AFKL airlines) between two airports on the
  given date.
  """
  @spec get_cheapest_offer(String.t, String.t, String.t) :: tuple
  def get_cheapest_offer(origin, destination, date) do
    Application.get_env(:airline_api_aggregator, :afkl)[:body]
    |> AirlineAPIAggregator.prepare_body(origin, destination, date)
    |> get_data
  end

  @doc """
  Get the cheapest flight from the given xml flight data. The XML is parsed using
  SweetXML library. The XML parsing is specific to AFKL airlines.
  """
  def parse_xml_and_get_cheapest_offer(xml) do
    xml
    |> xpath(~x"//AirlineOffers/Offer/TotalPrice/DetailCurrencyPrice/Total/text()"l)
    |> get_min_ticket()
  end

  #
  # Request data from airlines using http post requests. HTTPoison is used to
  # compose the http requests.
  # Status code other than 200 is considered as error.
  #
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

  #
  # Case where no flights are found for the route on the specified date.
  #
  defp get_min_ticket([]) do
    {:error, "No flights found."}
  end

  #
  # Flights are found in reponse xml from airline
  #
  defp get_min_ticket(ticket_list) do
    cheapest_ticket =
      ticket_list
      |> Enum.map(fn price ->
        price |> to_string |> String.to_float
      end)
      |> Enum.min

    {@airline_code, cheapest_ticket}
  end
end
