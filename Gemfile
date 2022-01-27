# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

gem 'aws-sdk-dynamodb', '~> 1.62'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'devise'
gem 'discard'
gem 'figaro'
gem 'grape'
gem 'grape-entity'
gem 'jbuilder', '~> 2.7'
gem 'okcomputer'
gem 'oktakit', git: 'https://github.com/charleystran/oktakit', branch: 'add_authorization_servers'
gem 'omniauth', '~> 2.0.0'
gem 'omniauth-github', github: 'omniauth/omniauth-github', branch: 'master'
gem 'omniauth-rails_csrf_protection'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.5'
gem 'rails', '~> 6.1.3', '>= 6.1.3.1'
gem 'rails_admin', '~> 2.0'
gem 'rails-healthcheck'
gem 'rest-client'
gem 'sass-rails', '>= 6'
gem 'serviceworker-rails'
gem 'simple_form'
gem 'socksify', '~> 1.7'
gem 'turbolinks', '~> 5'

group :development, :test do
  gem 'brakeman'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
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
  gem 'dotenv-rails'
  gem 'listen', '~> 3.3'
  gem 'pry-byebug'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'rubocop', require: false
  gem 'rubocop-rails'
  gem 'spring'
  gem 'web-console', '>= 4.1.0'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'simplecov', '< 0.18', require: false
  gem 'webdrivers'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
