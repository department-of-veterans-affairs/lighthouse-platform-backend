# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'webmock/rspec'
require 'support/factory_bot'

WebMock.disable_net_connect!(allow_localhost: true)

VCR::MATCH_EVERYTHING = { match_requests_on: %i[method uri headers body] }.freeze

module VCR
  def self.all_matches
    %i[method uri body]
  end
end

VCR.configure(&:configure_rspec_metadata!)

VCR.configure do |c|
  c.before_record(:force_utf8) do |interaction|
    interaction.response.body.force_encoding('UTF-8')
  end
  c.cassette_library_dir = 'spec/support/vcr_cassettes'
  c.hook_into :webmock
  c.default_cassette_options = { decode_compressed_response: true }
  c.ignore_request do |request|
    URI(request.uri).port.in?([8000, 8001])
  end
  c.ignore_hosts '127.0.0.1', 'localhost'
end

ActiveRecord::Migration.maintain_test_schema!

require 'sidekiq/testing'
Sidekiq::Testing.fake!

FactoryBot::SyntaxRunner.class_eval do
  include RSpec::Mocks::ExampleMethods
end

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # Include devise sign_in helpers for request specs
  config.include Devise::Test::IntegrationHelpers, type: :request

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.before do
    Sidekiq::Worker.clear_all
  end
end
