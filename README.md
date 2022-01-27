# Lighthouse Platform Backend (LPB) 

## Getting Started

#### Running entirely through docker
```
docker-compose up -d
```
App should be available on localhost:8080

#### Running application natively and only dependencies through docker
```
docker-compose -f docker-compose.override.yml up -d
rake db:create
rake db:migrate
rake db:seed
rake dynamo:migrate
rake dynamo:seed
rake kong:seed_gateway
rake kong:seed_consumers
rake elasticsearch:seed

rails s
```
App should be available on localhost:8080


## Okta Interactions
These interactions require an api token created in your developer instance:
Okta Admin UI > Security > API > Tokens > Create Token
This token should then be added to application.yml as the value for 'okta_token'

Part of the business logic around Okta in this project requires a group to exist within your developer instance.
Okta Admin UI > Directory > Groups > Add Group
Then take the id of this group from the url:
https://dev-########-admin.okta.com/admin/group/{20-character-id}
and add it to your application.yml file as the value for 'idme_group_id'
