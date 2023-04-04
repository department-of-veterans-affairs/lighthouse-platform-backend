# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiCategory, type: :model do
  subject do
    ApiCategory.new(
      key: 'some cool key',
      url_slug: 'some cool slug'
    )
  end

  describe "tests a valid 'ApiCategory' model" do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'tests an incorrect input' do
    it "will be invalid without a 'url_slug' field" do
      subject.url_slug = nil
      expect(subject).not_to be_valid
    end
  end
end
