# frozen_string_literal: true

require 'rails_helper'

describe Users::OmniauthCallbacksController, type: :request do
  describe 'Github Auth' do
    it 'redirects users if they are not an admin' do
      setup_github_login 'John Smith', 'john@example.com', false
      user = User.create!(email: 'john@example.com', first_name: 'John', last_name: 'Smith', uid: '123545')
      sign_in user
      get '/platform-backend/users/auth/github/callback'

      expect(user.role).to eq 'user'
    end

    it 'creates a new user if it doesn\'t find an existing one' do
      setup_github_login 'John Smith', 'jsmith@example.com', true
      user = User.create!(email: 'user@example.com', first_name: 'John', last_name: 'Smith', uid: '123545')
      sign_in user
      get '/platform-backend/users/auth/github/callback'

      expect(User.count).to eq 2
    end

    it 'sets the users role based on their current teams' do
      setup_github_login 'John Smith', 'john@example.com', true
      user = User.create!(email: 'john@example.com', first_name: 'John', last_name: 'Smith', uid: '123545')
      sign_in user
      get '/platform-backend/users/auth/github/callback'

      expect(User.count).to eq 1
      user = User.where(email: 'john@example.com').first
      expect(user.role).to eq 'admin'
    end

    it 'redirects if the user has invalid information' do
      setup_github_login '', 'john@example.com', true
      user = User.create!(email: 'john@example.com', first_name: 'John', last_name: 'Smith')
      sign_in user
      get '/platform-backend/users/auth/github/callback'

      expect(response).to have_http_status(:redirect)
    end
  end
end

def setup_github_login(name, email, is_admin) # rubocop:disable Metrics/MethodLength
  admin_team = '[{"id": "0", "name": "name in response"}]'
  non_admin_team = '[{"id": "1", "name": "not admin team"}]'

  stub_request(:get, 'https://api.github.com/user/teams?page=1')
    .with(
      headers: { Accept: 'application/vnd.github.v3+json' }
    )
    .to_return(
      body: is_admin ? admin_team : non_admin_team,
      headers: { 'Content-Type': 'application/json' },
      status: 200
    )

  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
                                                                provider: 'github',
                                                                uid: '123545',
                                                                info: {
                                                                  uid: '123545',
                                                                  name: name,
                                                                  email: email
                                                                },
                                                                credentials: {
                                                                  token: '123456',
                                                                  expires_at: Time.zone.now + 1.week
                                                                }
                                                              })
end
