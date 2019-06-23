defmodule AirlineAPIAggregator.APIBehaviour do
  @moduledoc """
  Behaviour for the connected airlines API. Provides a unified specsheet about
  the function arguements and return types.
  """
  @callback get_cheapest_offer(origin :: String.t, destination :: String.t,
                              date :: String.t) :: tuple()

  @callback parse_xml_and_get_cheapest_offer(xml :: binary) :: tuple()

end
