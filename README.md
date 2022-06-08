# Lighthouse Platform Backend (LPB) 

## About

This service is the "source of truth" for information regarding a Lighthouse API consumer.
It provides data about consumers that can be retrieved and processed by various Lighthouse systems, such as SalesForce.
These internal systems can then manage Lighthouse consumers, such as promoting a consumer from sandbox to the production environment.

## Deployment

Service lives within the DVP environment and can be found here in production: https://blue.production.lighthouse.va.gov/platform-backend
within the VA network. 

Deploying to production requires a Maintenance Request (MR)
An MR can be created here: https://github.com/department-of-veterans-affairs/lighthouse-devops-support/issues/new/choose

MR Example here: https://github.com/department-of-veterans-affairs/lighthouse-devops-support/issues/1314

Jenkins CI build for master branch can be found here: https://tools.health.dev-developer.va.gov/jenkins/job/department-of-veterans-affairs/job/lighthouse-platform-backend/job/master/

Deployment repository for this project can be found here: https://github.com/department-of-veterans-affairs/lighthouse-platform-backend-deployment


## Getting Started

Copy `application.yml.sample` to `application.yml` and make any necessary changes.
Note: Okta can not be run within a docker container, so additional configuration is required to first set up a developer account and point this application there.

#### Running entirely through docker
```
docker-compose -f docker-compose.yml -f docker-compose.ports.yml -f docker-compose.dependencies.yml -f docker-compose.dependencies.ports.yml up -d
```
App should be available on localhost:8080

Note: First run requires database migration and seeding. Exec into the app container and run the following:
```
rake db:create
rake db:migrate
rake db:seed
```

#### Running application natively and only dependencies through docker
```
docker-compose -f docker-compose.dependencies.yml -f docker-compose.dependencies.ports.yml up -d

export DATABASE_HOST=localhost
export DATABASE_USER=postgres
export DATABASE_PASSWORD=postgres
export RAILS_SERVE_STATIC_FILES=true
export RAILS_ENV=development

rake db:create
rake db:migrate
rake db:seed
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
