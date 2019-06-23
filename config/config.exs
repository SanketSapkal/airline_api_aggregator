use Mix.Config

config :airline_api_aggregator, :ba,
  url: "https://test.api.ba.com/selling-distribution/AirShopping/V2",
  headers: [{"Content-Type", "application/xml"},
            {"Client-Key", "czrzswga6x3gy3uutvfy9um2"},
            {"Soapaction", "AirShoppingV01"}],
  body: ~s(<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
            <s:Body xmlns="http://www.iata.org/IATA/EDIST">
              <AirShoppingRQ Version="3.0" xmlns="http://www.iata.org/IATA/EDIST">
                <PointOfSale><Location><CountryCode>DE</CountryCode></Location></PointOfSale><Document/>
                <Party><Sender><TravelAgencySender><Name>test agent</Name><IATA_Number>00002004</IATA_Number><AgencyID>test agent</AgencyID></TravelAgencySender></Sender></Party>
                <Travelers><Traveler><AnonymousTraveler><PTC Quantity="1">ADT</PTC></AnonymousTraveler></Traveler></Travelers>
                <CoreQuery>
                  <OriginDestinations><OriginDestination>
                    <Departure>
                      <AirportCode>ORIGIN_AIRPORT</AirportCode>
                      <Date>TRAVEL_DATE</Date>
                    </Departure>
                    <Arrival>
                      <AirportCode>DESTINATION_AIRPORT</AirportCode>
                    </Arrival>
                  </OriginDestination></OriginDestinations>
                </CoreQuery>
              </AirShoppingRQ>
            </s:Body>
          </s:Envelope>)

config :airline_api_aggregator, :afkl,
  url: "https://ndc-rct.airfranceklm.com/passenger/distribmgmt/001448v01/EXT",
  headers: [{"Content-Type", "text/xml"},
            {"SOAPAction", ~s("http://www.af-klm.com/services/passenger/ProvideAirShopping/provideAirShopping")},
            {"api_key", "mdug6d7y75e36vvpa487j5k7"}],
  body: ~s(<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\">
            <soapenv:Header/><soapenv:Body xmlns=\"http://www.iata.org/IATA/EDIST/2017.1\">
              <AirShoppingRQ Version=\"17.1\"><Document/>
                <Party><Sender><TravelAgencySender><Name>Test</Name><PseudoCity>PARMM211L</PseudoCity><IATA_Number>12345675</IATA_Number><AgencyID>id</AgencyID></TravelAgencySender></Sender><Recipient><ORA_Recipient><AirlineID>AF</AirlineID></ORA_Recipient></Recipient></Party>
                <CoreQuery>
                  <OriginDestinations><OriginDestination>
                    <Departure>
                      <AirportCode>ORIGIN_AIRPORT</AirportCode>
                      <Date>TRAVEL_DATE</Date>
                    </Departure>
                    <Arrival>
                      <AirportCode>DESTINATION_AIRPORT</AirportCode>
                    </Arrival></OriginDestination>
                  </OriginDestinations>
                </CoreQuery>
                <Preference><CabinPreferences><CabinType><Code>1</Code></CabinType></CabinPreferences></Preference>
                <DataLists><PassengerList><Passenger><PTC>ADT</PTC></Passenger></PassengerList></DataLists>
              </AirShoppingRQ>
            </soapenv:Body>
          </soapenv:Envelope>)

config :airline_api_aggregator, :rate_limiter,
  tokens_per_day: 100,
  tokens_per_second: 3
