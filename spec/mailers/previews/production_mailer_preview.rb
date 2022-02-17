# frozen_string_literal: true

require 'factory_bot_rails'

class ProductionMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods

  def consumer_production_access
    ProductionMailer.consumer_production_access(request)
  end

  def support_production_access
    ProductionMailer.support_production_access(request)
  end

  private

  def request
    build(:production_access_request)
  end
end
