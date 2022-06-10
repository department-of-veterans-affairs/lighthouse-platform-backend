# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = false
  config.action_view.cache_template_loading = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  config.active_job.queue_adapter = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true
  ENV['SLACK_WEBHOOK_URL'] = 'https://www.slack.com'
  ENV['GITHUB_EMAIL_DEFAULT_EMAIL_ADDRESS'] = 'testing@example.com'
  ENV['DSVA_ENVIRONMENT'] = 'Development'
  ENV['DYNAMO_ACCESS_KEY_ID'] = 'iammocked'
  ENV['DYNAMO_SECRET_ACCESS_KEY'] = 'iammocked'
  ENV['DYNAMO_TABLE_NAME'] = 'mocktable'
  ENV['DYNAMO_ENDPOINT'] = 'http://dynamodb:8000'
  ENV['OKTA_TOKEN'] = 'mocktoken'
  ENV['PROD_OKTA_TOKEN'] = 'mocktoken'
  ENV['OKTA_API_ENDPOINT'] = 'https://deptva-eval.okta.com/api/v1'
  ENV['PROD_OKTA_API_ENDPOINT'] = 'https://deptva-eval.okta.com/api/v1'
  ENV['OKTA_TOKEN_VALIDATION_ENDPOINT'] = 'https://deptva-eval.okta.com'
  ENV['OKTA_LOGIN_URL'] = 'https://sandbox-api.va.gov/oauth2/redirect/'
  ENV['PROD_OKTA_LOGIN_URL'] = 'https://api.va.gov/oauth2/redirect/'
  ENV['OKTA_DEFAULT_POLICY'] = 'Default Policy'
  ENV['OKTA_AUTH_SERVER'] = 't35t1d'
  ENV['OKTA_CLIENT_ID'] = 'cl13nt_1d'
  ENV['OKTA_CLIENT_SECRET'] = 'n0_0n3_kn0w5'
  ENV['IDME_GROUP_ID'] = '00g31dz5agb5ZzIk05d7'
  ENV['PROD_IDME_GROUP_ID'] = '00g31dz5agb5ZzIk05d7'
  ENV['KONG_ELB'] = 'http://kong:8001'
  ENV['PROD_KONG_ELB'] = 'http://prod-kong:8001'
  ENV['AWS_REGION'] = 'us-gov-west-1'
  ENV['AUTHZ_SERVER_DEFAULT'] = 'default'
  ENV['ES_ENDPOINT'] = 'http://elasticsearch:9200'
  ENV['SUPPORT_EMAIL'] = 'user_support@the_house_of_light.com'
  ENV['VA_PROFILE_DISTRIBUTION'] = 'va_profile_support@the_house_of_light.com'
  ENV['SLACK_API_TOKEN'] = 't4c0s4lyf3'
  ENV['SLACK_DRIFT_CHANNEL'] = '#test'
  ENV['SLACK_SIGNUP_CHANNEL'] = '#test'
  ENV['ENABLE_GITHUB_AUTH'] = 'false'
end
