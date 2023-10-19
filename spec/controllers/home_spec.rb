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
        api = create(:api)
        api_slug = api.api_metadatum.url_slug

        # indicate that this API should not have a sandbox access form
        api.api_metadatum.block_sandbox_form = true
        api.api_metadatum.save!

        get '/platform-backend/sitemap.xml'
        temp = Hash.from_xml(response.body)

        has_sanbox_access_url = temp['urlset']['url'].any? { |url| url['loc'] == "https://developer.va.gov/explore/api/#{api_slug}/sandbox-access" }

        expect(response).to have_http_status(:success)
        expect(has_sanbox_access_url).to be false
      end
    end

    context 'when an API does not block the sandbox access form' do
      it "does include the 'sandbox access form' url" do
        api = create(:api)
        api_slug = api.api_metadatum.url_slug

        # indicate that this API should have a sandbox access form
        api.api_metadatum.block_sandbox_form = false
        api.api_metadatum.save!

        get '/platform-backend/sitemap.xml'
        temp = Hash.from_xml(response.body)

        has_sanbox_access_url = temp['urlset']['url'].any? { |url| url['loc'] == "https://developer.va.gov/explore/api/#{api_slug}/sandbox-access" }

        expect(response).to have_http_status(:success)
        expect(has_sanbox_access_url).to be true
      end
    end

    context 'when an API has deactivation info' do
      it 'does not include the API in the list of urls' do
        api = create(:api)

        api.api_metadatum.deactivation_info = JSON.parse('{"deprecationContent":"Dummy content is acceptable."}')
        api.api_metadatum.save!

        get '/platform-backend/sitemap.xml'
        temp = Hash.from_xml(response.body)

        has_any_url = temp['urlset'].key?('url')

        expect(response).to have_http_status(:success)
        expect(has_any_url).to be false
      end
    end

    context 'when an API is stealth launched' do
      it 'does not include the API in the list of urls' do
        api = create(:api)

        api.api_metadatum.is_stealth_launched = true
        api.api_metadatum.save!

        get '/platform-backend/sitemap.xml'
        temp = Hash.from_xml(response.body)

        has_any_url = temp['urlset'].key?('url')

        expect(response).to have_http_status(:success)
        expect(has_any_url).to be false
      end
    end

    it "includes the API's base 'explore' url" do
      api = create(:api)
      api_slug = api.api_metadatum.url_slug

      get '/platform-backend/sitemap.xml'
      temp = Hash.from_xml(response.body)

      has_explore_url = temp['urlset']['url'].any? { |url| url['loc'] == "https://developer.va.gov/explore/api/#{api_slug}" }

      expect(response).to have_http_status(:success)
      expect(has_explore_url).to be true
    end
  end
end
