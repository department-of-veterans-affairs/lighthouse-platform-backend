# frozen_string_literal: true

class GithubMailer < ApplicationMailer
  default from: 'noreply@vasecretscanner.gov'
  default to: ENV['GITHUB_EMAIL_DEFAULT_EMAIL_ADDRESS']

  def security_email(body)
    @secret_type = body.dig(:alert, :secret_type)
    @repo_name = body.dig(:repository, :full_name)
    @repo_url = body.dig(:repository, :html_url)
    @org_name = body.dig(:organization, :login)

    mail(
      subject: 'Github Secret Scanner Alert',
      template_path: 'github',
      template_name: 'github_mailer'
    )
  end
end
