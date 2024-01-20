# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").strip

gem 'activerecord-import'
gem 'aws-sdk-dynamodb', '~> 1.62'
gem 'aws-sdk-s3', '~> 1.114'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'devise'
gem 'discard'
gem 'figaro'
gem 'flipper'
gem 'flipper-active_record'
gem 'flipper-ui'
gem 'govdelivery-tms', require: 'govdelivery/tms/mail/delivery_method'
gem 'grape'
gem 'grape-entity'
gem 'grape_logging'
gem 'grape-swagger'
gem 'grape-swagger-rails'
gem 'httparty'
gem 'jbuilder', '~> 2.7'
gem 'jwt'
gem 'lograge'
gem 'okcomputer'
gem 'oktakit', git: 'https://github.com/FonzMP/oktakit', branch: 'add_auth_servers'
gem 'omniauth', '~> 2.0.0'
gem 'omniauth-github', github: 'omniauth/omniauth-github', branch: 'master'
gem 'omniauth-rails_csrf_protection'
gem 'pg', '~> 1.1'
gem 'premailer-rails'
gem 'puma', '~> 5.6'
gem 'rack-protection', '< 2.2.0'
gem 'rails'
gem 'rails_admin', '~> 3.0'
gem 'rails-healthcheck'
gem 'redcarpet', '~> 3.6'
gem 'rest-client'
gem 'rufus-scheduler'
gem 'sass-rails', '>= 6'
gem 'serviceworker-rails'
gem 'simple_form'
gem 'slack-ruby-client'
gem 'socksify', '~> 1.7'
gem 'turbolinks', '~> 5'

group :development, :test do
  gem 'brakeman'
  gem 'factory_bot_rails', '> 5'
  gem 'faker'
  gem 'rspec-rails', '~> 5.0.0'
  gem 'rubocop-rspec'
  gem 'rubocop-thread_safety'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  gem 'bullet'
  gem 'bundler-audit', require: false
  gem 'debug', '>= 1.0.0'
  gem 'dotenv-rails'
  gem 'listen', '~> 3.3'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'rubocop', require: false
  gem 'rubocop-rails'
  gem 'spring'
  gem 'web-console', '>= 4.1.0'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'simplecov-csv', require: false
  gem 'webdrivers'
end

gem 'sassc-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
