# frozen_string_literal: true

require 'rails_helper'

describe V0::Environments, type: :request do
  let(:environment_id) { Environment.first.id }

  before do
    create_list(:environment, 3)
  end

  it 'returns a list of environments' do
    get '/platform-backend/v0/environments'
    expect(response.code).to eq('200')
    expect(JSON.parse(response.body).count).to eq(3)
  end

  it 'locates an environment by id' do
    get "/platform-backend/v0/environments/#{environment_id}"
    expect(response.code).to eq('200')
    expect(JSON.parse(response.body)['id']).to eq(environment_id)
  end
end
