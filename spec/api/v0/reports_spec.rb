# frozen_string_literal: true

require 'rails_helper'

describe V0::Reports, type: :request do
  describe 'reports api' do
    let(:user) { create(:user) }
    let(:consumer) { create(:consumer, :with_sandbox_ids, user: user) }

    before do
      user
      consumer
    end

    it 'returns a successful first call' do
      get "/platform-backend/v0/reports/first-call/#{user[:id]}"
      expect(response.code).to eq('200')

      expect(response.body).to include('July 03, 2015')
    end
  end
end
