# frozen_string_literal: true

require 'rails_helper'

describe Users::OmniauthCallbacksController, type: :request do
  describe 'Github Auth' do
    it 'creates a new user if it doesn\'t find an existing one' do
      setup_github_login 'John Smith', 'jsmith@example.com'
      user = User.create!(email: 'user@example.com', first_name: 'John', last_name: 'Smith', uid: '123545')
      sign_in user
      get '/platform-backend/users/auth/github/callback'

      expect(User.count).to eq 2
    end

    it 'sets the users role based on their current teams' do
      setup_github_login 'John Smith', 'john@example.com'
      user = User.create!(email: 'john@example.com', first_name: 'John', last_name: 'Smith', uid: '123545')
      sign_in user
      get '/platform-backend/users/auth/github/callback'

      expect(User.count).to eq 1
      user = User.where(email: 'john@example.com').first
      expect(user.role).to eq 'admin'
    end
  end
end

def setup_github_login(name, email) # rubocop:disable Metrics/MethodLength
  stub_request(:get, 'https://api.github.com/user/teams?page=1')
    .with(
      headers: { Accept: 'application/vnd.github.v3+json' }
    )
    .to_return(
      body: '[{"id": "0", "name": "name in response"}]',
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
