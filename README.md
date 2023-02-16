# Lighthouse Platform Backend (LPB)

## About

This service is the "source of truth" for information regarding a Lighthouse API consumer.
It provides data about consumers that can be retrieved and processed by various Lighthouse systems, such as SalesForce.
These internal systems can then manage Lighthouse consumers, such as promoting a consumer from sandbox to the production environment.


## Auto-Deployment Lifecycle
Service lives within the DVP environment and can be found here in production: https://blue.production.lighthouse.va.gov/platform-backend
within the VA network.  

Deployment repository for this project can be found here: https://github.com/department-of-veterans-affairs/lighthouse-platform-backend-deployment

- Once a PR is merged into Master ::
  - a [Jenkins CI build](https://tools.health.dev-developer.va.gov/jenkins/job/department-of-veterans-affairs/job/lighthouse-platform-backend/job/master/) is started and if everything builds successfully, the Jenkins CI job will create and publish a [GitHub Release in the LPB Repo](https://github.com/department-of-veterans-affairs/lighthouse-platform-backend/releases).
  - Once the GitHub Release is published, that will trigger the [`Create Auto Deploy Maintenance Request`](https://github.com/department-of-veterans-affairs/lighthouse-platform-backend/blob/master/.github/workflows/create-auto-deploy-maintenance-request.yml#L1) GitHub Action (GHA) Workflow.
    - The `Create Auto Deploy Maintenance Request` workflow will check to see if there are any active LPB Maintenance Requests (MR) in the [Lighthouse DevOps Support](https://github.com/department-of-veterans-affairs/lighthouse-devops-support/issues) repo.
      - If there is an active LPB MR, then do nothing and exit the `Create Auto Deploy Maintenance Request` workflow.  
      - If there is NOT an active LPB MR ::
        - auto-generate a new LPB MR ([see an example](https://github.com/department-of-veterans-affairs/lighthouse-devops-support/issues/2182))
          - scheduled for 10am (eastern time) the next day (or the next Monday if the current day is a Friday)
          - add a `MR in progress` label to all open PR's in the LPB repo
          - enable the [`Auto Deploy master to Production`](https://github.com/department-of-veterans-affairs/lighthouse-platform-backend/blob/master/.github/workflows/auto-deploy-to-production.yml#L1) GHA workflow.
  - The `Auto Deploy master to Production` workflow will periodically check to see if there is an approved LPB MR in the [Lighthouse DevOps Support](https://github.com/department-of-veterans-affairs/lighthouse-devops-support/issues) repo that matches the current day/time.
    - When the workflow finds an approved LPB MR that matches the current day/time, the workflow will trigger a [Jenkins CI build of the `health-apis-deploy` job](https://tools.health.dev-developer.va.gov/jenkins/job/department-of-veterans-affairs/job/health-apis-deployer/job/d2/) which will deploy the changes to production.
    - After the job successfully deploys to production, the workflow will ::
      - Update the LPB MR with the start-time, end-time, and a link to the Jenkins job that peformed the deployment.
      - Remove the `MR in prgoress` labels from all open PR's in the LPB repo.
      - Disable the [`Auto Deploy master to Production`](https://github.com/department-of-veterans-affairs/lighthouse-platform-backend/blob/master/.github/workflows/auto-deploy-to-production.yml#L1) GHA Workflow.


## Getting Started

Copy `config/application.yml.sample` to `config/application.yml` and make any necessary changes.
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
rake dynamo:seed
rake kong:seed
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

## Testing
LPB uses [RSpec](https://rspec.info/documentation/) alongside [VCR](https://github.com/vcr/vcr) to execute the test suite. VCR uses what they call '[cassettes](https://relishapp.com/vcr/vcr/v/6-1-0/docs/cassettes)' which record requests and replay the response when rerunning the test suite, preventing calls to an external service (if applicable). To best utilize VCR, any external requests should be recorded and later used for testing purposes to prevent said calls. The resulting cassettes can be matched on various request methods.

In it's current state, LPB containers are pre-seeded using the [seed_service](app/services/utility/seed_service.rb) to best simulate a 'live' environment. Due to the aforementioned, VCR is configured to ignore any requests to the docker container.
For any test using a local container, update the seed service with the needed data and use the connected container to test against.
