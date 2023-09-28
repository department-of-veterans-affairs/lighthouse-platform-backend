# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homes', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/platform-backend'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /sitemap.xml', type: :request do
    context 'when an API does not have Oauth' do
      it "does not include 'ACG' or 'CCG' urls" do
        api = create(:api)
        api_slug = api.api_metadatum.url_slug

        # remove the APIs Oauth stuffs
        api.api_metadatum.oauth_info = {}
        api.api_metadatum.save!

        get '/platform-backend/sitemap.xml'
        temp = Hash.from_xml(response.body)

        has_acg_url = temp['urlset']['url'].any? { |url| url['loc'] == "https://developer.va.gov/explore/api/#{api_slug}/authorization-code" }
        has_ccg_url = temp['urlset']['url'].any? { |url| url['loc'] == "https://developer.va.gov/explore/api/#{api_slug}/client-credentials" }

        expect(response).to have_http_status(:success)
        expect(has_acg_url).to be false
        expect(has_ccg_url).to be false
      end
    end

    context 'when an API does have Oauth' do
      it "does include the 'ACG' and 'CCG' urls" do
        api = create(:api)
        api_slug = api.api_metadatum.url_slug

        get '/platform-backend/sitemap.xml'
        temp = Hash.from_xml(response.body)

        has_acg_url = temp['urlset']['url'].any? { |url| url['loc'] == "https://developer.va.gov/explore/api/#{api_slug}/authorization-code" }
        has_ccg_url = temp['urlset']['url'].any? { |url| url['loc'] == "https://developer.va.gov/explore/api/#{api_slug}/client-credentials" }

        expect(response).to have_http_status(:success)
        expect(has_acg_url).to be true
        expect(has_ccg_url).to be true
      end
    end

    context 'when an API blocks the sandbox access form' do
      it "does not include the 'sanbox access form' url" do
        # setup code goes here
        get '/platform-backend/sitemap.xml'
        # expectation code goes here
        expect(response).to have_http_status(:success)
      end
    end

    context 'when an API does not block the sandbox access form' do
      it "does include the 'sanbox access form' url" do
        # setup code goes here
        get '/platform-backend/sitemap.xml'
        # expectation code goes here
        expect(response).to have_http_status(:success)
      end
    end

    it "includes the API's base 'explore' url" do
      # setup code goes here
      get '/platform-backend/sitemap.xml'
      # expectation code goes here
      expect(response).to have_http_status(:success)
    end
  end
end
