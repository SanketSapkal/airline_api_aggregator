defmodule AirlineAPIAggregator.Router do

  use Plug.Router
  plug :match
  plug :dispatch

  get "/findCheapestOffer" do
    conn = fetch_query_params(conn)

    %{"origin" => origin, "destination" => destination, "departureDate" => date} = conn.params

    result = AirlineAPIAggregator.get_cheapest_flight(origin, destination, date)
    
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(result))
  end

  # TODO: Add a proper error message here.
  match _ do
    send_resp(conn, 404, "Please try again")
  end

end
