# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apigee::ServiceFactory do
  it 'raises an exception if invalid environment provided' do
    expect { Apigee::ServiceFactory.service(:invalid) }.to raise_error(StandardError)
  end
end
