# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api, type: :model do
  describe 'tests a valid Api model' do
    subject do
      Api.new(name: 'Appeals Status API',
              acl: 'lca')
    end

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'requires a name to be valid' do
      expect(subject.name).to eq('Appeals Status API')
    end

    it 'requires an acl to be valid' do
      expect(subject.acl).to eq('lca')
    end
  end

  describe 'tests an incorrect input' do
    it 'will be invalid without a name' do
      subject.name = nil
      expect(subject).not_to be_valid
    end
  end

  describe 'tests a valid Api record' do
    subject do
      create(:api)
    end

    let(:category) { create(:api_category) }

    it 'undiscards a previously discarded record' do
      subject.discard
      expect(subject.discarded_at).not_to be_nil
      subject.undiscard
      expect(subject.discarded_at).to be_nil
    end

    it 'discards a previously undiscarded record' do
      expect(subject.discarded_at).to be_nil
      subject.discard
      expect(subject.discarded_at).not_to be_nil
    end

    it 'activates an api' do
      subject.activate!
    end

    it 'deactivates an api' do
      subject.deactivate!(deactivation_date: Time.zone.now, deactivation_content: 'content-here')
    end

    it 'deprecates an api' do
      subject.deprecate!(deprecation_date: Time.zone.now, deprecation_content: 'content-here')
    end

    it 'api_environments_attributes=' do
      subject.api_environments_attributes = {
        environments_attributes: {
          name: ['name-here'],
          metadata_url: 'url/here'
        }
      }
    end

    it 'api_ref_attributes=' do
      subject.api_ref_attributes = {
        name: 'name-here'
      }
    end

    it 'api_metadatum_attributes=' do
      subject.api_metadatum_attributes = {
        api_category_attributes: {
          id: category.id
        },
        description: 'description-here',
        display_name: 'display-name-here',
        open_data: false,
        va_internal_only: false,
        url_fragment: 'url-fragment-here'
      }
    end
  end

  describe "'locate_auth_types'" do
    context 'when the api has all auth types' do
      subject do
        create(:api)
      end

      it 'correctly returns all auth types' do
        auth_types = subject.locate_auth_types

        expect(auth_types).to include('apikey')
        expect(auth_types).to include('oauth/acg')
        expect(auth_types).to include('oauth/ccg')
      end
    end

    context "when the api does not support the 'apiKey' auth type" do
      subject do
        create(:api_without_acl)
      end

      it "does not contain the 'apiKey' auth type" do
        auth_types = subject.locate_auth_types

        expect(auth_types).not_to include('apikey')
        expect(auth_types).to include('oauth/acg')
        expect(auth_types).to include('oauth/ccg')
      end
    end

    context "when the api does not support the 'acg' auth type" do
      subject do
        create(:api_without_acg)
      end

      it "does not contain the 'oauth/acg' auth type and does not blow up" do
        auth_types = subject.locate_auth_types

        expect(auth_types).to include('apikey')
        expect(auth_types).not_to include('oauth/acg')
        expect(auth_types).to include('oauth/ccg')
      end
    end

    context "when the api does not support the 'ccg' auth type" do
      subject do
        create(:api_without_ccg)
      end

      it "does not contain the 'oauth/ccg' auth type and does not blow up" do
        auth_types = subject.locate_auth_types

        expect(auth_types).to include('apikey')
        expect(auth_types).to include('oauth/acg')
        expect(auth_types).not_to include('oauth/ccg')
      end
    end
  end
end
