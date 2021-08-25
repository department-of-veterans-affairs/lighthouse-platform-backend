# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KongService do
  describe 'importing consumers from dynamo and Kong' do
    it 'imports the the users' do
      service = ConsumerImportService.new
      expect do
        service.import
      end.to change(User, :count).by(1)
    end
  end
end
