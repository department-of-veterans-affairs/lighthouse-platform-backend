# frozen_string_literal: true

require 'rails_helper'

describe GithubController, type: :request do
  let(:valid_params) do
    {
      alert: {
        secret_type: 'adafruit_io_key'
      },
      repository: {
        full_name: 'Codertocat/Hello-World',
        html_url: 'https://github.com/Codertocat/Hello-World'
      },
      organization: {
        login: 'Codertocat'
      }
    }
  end

  it 'responds with a 204 when passed a valid body' do
    VCR.use_cassette('github_alert', match_requests_on: [:method]) do
      post('/platform-backend/github', params: valid_params)
      expect(response.code).to eq('204')
    end
  end

  it 'responds with an exception when passed an invalid body' do
    expect  do
      post('/platform-backend/github', params: { boop: 'bap' })
    end.to raise_error(ActionController::ParameterMissing)
  end
end
