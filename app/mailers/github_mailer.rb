# frozen_string_literal: true

class GithubMailer < ApplicationMailer
  default from: 'noreply@vasecretscanner.gov'
  default to: ENV['GITHUB_EMAIL_DEFAULT_EMAIL_ADDRESS']

  def security_email(body)
    @secret_type = body[:alert][:secret_type]
    @repo_name = body[:repository][:full_name]
    @repo_url = body[:repository][:html_url]
    @org_name = body[:organization][:login]

    mail(
      subject: 'Github Secret Scanner Alert',
      template_path: 'github',
      template_name: 'github_mailer'
    )
  end
end
