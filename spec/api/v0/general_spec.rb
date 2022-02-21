# frozen_string_literal: true

require 'rails_helper'

describe V0::Consumers, type: :request do
  context 'when path is unknown' do
    it 'responds with a 404 status' do
      get '/platform-backend/v0/invalid/path/here'
      expect(response.code).to eq('404')
    end
  end
end
