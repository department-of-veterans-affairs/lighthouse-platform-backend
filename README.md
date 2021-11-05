## Kong Gateway
The docker-compose file provides a containerized version of the existing Kong Gateway (2.3.2). This gives developers the ability to implement functionality that interacts with an existing Kong Gateway, in a controlled, local environment. In the event that you would need to develop against two Kong instances (ex: sandbox Kong -> prod Kong), we recommend using the existing `lighthouse-api-gateway` repository as a secondary. To run the dockerized version of Kong by itself, run `docker-compose up -d kong kong-migrations kong-database`.

# Seeding the Gateway
Rake tasks have been created to assist in generating data within Kong. These are provided as additional services and are not initiated at startup. These services are also used by the test suite to generate the necessary data for testing purposes within the CI task.

`rake kong:seed_gateway` is a generalized task that is structured to combine all existing 'seeds'.
`rake kong:seed_consumers` generates consumers within the gateway.