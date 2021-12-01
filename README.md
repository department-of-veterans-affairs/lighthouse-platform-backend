# [LPB] Lighthouse Platform Backend

### Environment
1. Copy `config/application.yml.sample` to `config/application.yml`
2. Create a developer okta account: https://developer.okta.com/
3. Populate application.yml file with your okta information
4. Run `docker-compose up -d` to bring up dependencies
5. Run
```
rake db:create
rake db:migrate
rake db:seed
```

### Migrating existing structure
```
rake dynamo:migrate
rake dynamo:seed
rake "load_apis[spec/support/apis_list.csv, http://localhost:8080]"
rake load_consumers

```

### Loading APIs
User creation is dependent on APIs existing within the application. You can add an API by running the `load_apis` rake task above. If you prefer, you can use the admin dashboard at `/platform-backend/admin/dashboard` to upload a CSV with the respective information. An example has been provided for you within `spec/support/apis_list.csv`.

## Kong Interactions

### Kong Gateway
The docker-compose file provides a containerized version of the existing Kong Gateway (2.3.2). This gives developers the ability to implement functionality that interacts with an existing Kong Gateway, in a controlled, local environment. In the event that you would need to develop against two Kong instances (ex: sandbox Kong -> prod Kong), we recommend using the existing `lighthouse-api-gateway` repository as a secondary. To run the dockerized version of Kong by itself, run `docker-compose up -d kong kong-migrations kong-database`.

### Seeding the Gateway
Rake tasks have been created to assist in generating data within Kong. These are provided as additional services and are not initiated at startup. These services are also used by the test suite to generate the necessary data for testing purposes within the CI task.

`rake kong:seed_gateway` is a generalized task that is structured to combine all existing 'seeds'.
`rake kong:seed_consumers` generates consumers within the gateway.
