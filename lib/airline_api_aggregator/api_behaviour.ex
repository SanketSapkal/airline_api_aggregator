defmodule AirlineAPIAggregator.APIBehaviour do

  @callback get_cheapest_offer(origin :: String.t, destination :: String.t,
                              date :: String.t) :: tuple()

  @callback parse_xml(xml :: binary) :: tuple()

end
