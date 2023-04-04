# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiMetadatum, type: :model do
  subject do
    ApiMetadatum.new(
      api_id: api.id,
      api_category_id: api_category.id,
      overview_page_content: 'some cool content',
      url_slug: 'some cool slug'
    )
  end

  let :api do
    create(:api)
  end

  let :api_category do
    create(:api_category)
  end

  describe "tests a valid 'ApiMetadatum' model" do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'tests an incorrect input' do
    it "will be invalid without an 'overview_page_content' field" do
      subject.overview_page_content = nil
      expect(subject).not_to be_valid
    end

    it "will be invalid without a 'url_slug' field" do
      subject.url_slug = nil
      expect(subject).not_to be_valid
    end
  end
end
