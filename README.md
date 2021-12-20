# Lighthouse Platform Backend (LPB) 

## Getting Started
To get the app running for the first time follow these steps:

1. Setup GitHub auth by following the [instructions below](#setting-up-github-auth)
1. Create a developer instance of Okta [here](https://developer.okta.com/)
1. Copy `config/application.yml.sample` to `config/application.yml` and set the env variables from GitHub and Okta
1. Run `docker-compose up -d` to bring up dependencies
1. Install gems with `bin/bundle install`
1. Create the database by running `bin/rake db:create`
1. Run the migrations with `bin/rake db:migrate`
1. Seed the database with `bin/rake db:seed`
1. Start the app by running `bin/rails server`

### Setting Up GitHub Auth
Lighthouse Platfrom Backend uses GitHub authentication so you'll need to setup an OAuth app, an organization and a team in GitHub before everything will work properly.

#### Create a GitHub OAuth app

https://docs.github.com/en/developers/apps/creating-an-oauth-app

In your github, create an OAuth application on your account.
- Set Homepage URL to http://localhost:8080
- Set Authorization Callback URL to http://localhost:8080/platform-backend/users/auth/github/callback

#### Create a github organization

https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch

#### Create a github team (with yourself in it)

- Go to your profile page
- Left-click on your organization image under 'Organizations'
- Click the Team tab
- Click 'New Team'
- Fill in the form with a team name. You can have the team as either public or secret.
- Click 'Create Team'

#### Get your github team id
- Go to your profile page
- Left-click on your organization image under 'Organizations'
- Click the Team tab
- Click on the team you just made
- Right-click on your team icon displayed on the page
- Click inspect in the context menu that opened in the previous step
  - Notice the developer console that opened in the last step
  - Look at the highlighted tag and grab the image src url
    - Ex: https://avatars.githubusercontent.com/t/12345678999?s=280&v=4
  - Note the number in the src url. This number is your github team id, which you'll need in setting up the app
      Ex: 123456789 - from the previous example

## Migrating existing structure
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

## Okta Interactions
These interactions require an api token created in your developer instance:
Okta Admin UI > Security > API > Tokens > Create Token
This token should then be added to application.yml as the value for 'okta_token'

Part of the business logic around Okta in this project requires a group to exist within your developer instance.
Okta Admin UI > Directory > Groups > Add Group
Then take the id of this group from the url:
https://dev-########-admin.okta.com/admin/group/{20-character-id}
and add it to your application.yml file as the value for 'idme_group_id'
