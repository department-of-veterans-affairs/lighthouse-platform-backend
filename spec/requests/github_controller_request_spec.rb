# frozen_string_literal: true

require 'rails_helper'

describe GithubController, type: :request do
  let(:github_alert_creator) { double(GithubAlertCreator) }

  before do
    allow(github_alert_creator).to receive(:call).and_return(:ok)
  end

  it 'responds with a 204' do
    VCR.use_cassette('github_alert') do
      post '/github'
      p response
    end
  end
end
