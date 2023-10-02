standardShellPipeline {
  dockerRegistryUrl = 'https://ghcr.io'
  dockerRegistryCredentialsId = 'GITHUB_USERNAME_TOKEN'
  credentials = [
    string(credentialsId:'SLACK_WEBHOOK_LIGHTHOUSE',variable: 'SLACK_WEBHOOK_LIGHTHOUSE')
  ]
  slackChannels = [ 
    'vaapi-cicd@${env.SLACK_WEBHOOK_LIGHTHOUSE}'
  ]
  timeout = 35
}
