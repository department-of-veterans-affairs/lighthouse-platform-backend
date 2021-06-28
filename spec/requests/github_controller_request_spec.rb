# frozen_string_literal: true

require 'spec_helper'
require_relative '../../app/controllers/github_controller'

describe GithubController, type: :request do
  let(:github_alert_creator) { double(GithubAlertCreator) }

  before do
    allow(github_alert_creator).to receive(:call).and_return(:ok)
  end

  it 'responds with a 204' do
    post '/github'
    p response
  end
end
