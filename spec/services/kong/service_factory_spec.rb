# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Kong::ServiceFactory do
  it 'raises an exception if invalid environment provided' do
    expect { Kong::ServiceFactory.service(:invalid) }.to raise_error(StandardError)
  end
end
