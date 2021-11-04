# Lighthouse Platform Backend (LPB) 

## Getting Started
To get the app running for the first time follow these steps:

1. Setup GitHub auth by following the [instructions below](#setting-up-github-auth)
1. Setup the environment by copying  `config/application.yml.sample` to `config/application.yml` and set the env variables from GitHub
1. Install dependecies with `bundle install`
1. Create the database by running `rails db:create`
1. Run the migrations with `rails db:migrate`
1. Start the app by running `rails server`

## Setting Up GitHub Auth
Lighthouse Platfrom Backend uses GitHub authentication so you'll need to setup an OAuth app, an organization and a team in GitHub before everything will work properly.

### Create a GitHub OAuth app

In your github, create an OAuth application on your account.
- Set Homepage URL to http://localhost:8080
- Set Authorization Callback URL to http://localhost:8080/platform-backend/users/auth/github/callback

https://docs.github.com/en/developers/apps/creating-an-oauth-app

### Create a github organization

https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch

### Create a github team (with yourself in it)

- Go to your profile page
- Left-click on your organization image under 'Organizations'
- Click the Team tab
- Click 'New Team'
- Fill in the form with a team name. You can have the team as either public or secret.
- Click 'Create Team'

### Get your github team id
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
