defmodule AirlineAPIAggregator.Router do
  @moduledoc """
  Routes the incoming request to the backend, currently support one api to get
  the cheapest flights.
  """

  use Plug.Router
  plug :match
  plug :dispatch

  get "/findCheapestOffer" do
    conn = fetch_query_params(conn)

    %{"origin" => origin, "destination" => destination, "departureDate" => date} = conn.params

    result = AirlineAPIAggregator.get_cheapest_flight(origin, destination, date)
    response_code = get_response_code(result)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(response_code, Poison.encode!(result))
  end

  match _ do
    send_resp(conn, 404, "API not found.")
  end

  defp get_response_code(%{data: %{error: "No flights found."}}), do: 204

  defp get_response_code(%{data: %{error: "No tokens availble, please try again later"}}), do: 429

  defp get_response_code(%{data: %{error: _reason}}), do: 500

  defp get_response_code(_no_error), do: 200
end
