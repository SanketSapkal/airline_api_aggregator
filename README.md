# AirlineAPIAggregator

Airline API Aggregator which helps the user to find cheapest flights among the
connected airlines.

It built using genserver for supervision, agent for rate limiting at the app side
and behaviour which makes it easy to integrate multiple airlines apis.

The ArilineAPIAggregator module also resets the daily tokens (max daily requests)
and the tokens per second(max requests per second).

The cheapest flights across the connected airlines are concurrently being get
and the cheapest among them is returned to the user.

## Environment details:
- elixir: 1.8
- erlang otp: 21

## Steps to follow:
  1. Change airlines configurations in config/config.exs
  2. Get the dependencies ```mix deps.get```
  3. Compile the dependencies ```mix deps.compile```
  4. Start the app - `iex -S mix`
  5. cURL command for cheapest flight: `curl -vv 'http://localhost:4000/findCheapestOffer?origin=BER&destination=LHR&departureDate=2019-07-17' -X GET `
