# frozen_string_literal: true

require 'factory_bot_rails'

class SupportMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods

  def consumer_support_email
    SupportMailer.consumer_support_email(default_request)
  end

  def publishing_support_email
    SupportMailer.publishing_support_email(publishing_request)
  end

  def publishing_support_email_internal
    SupportMailer.publishing_support_email(publishing_request_internal)
  end

  private

  def default_request
    build(:support_request)
  end

  def publishing_request
    build(:support_request, :set_publishing)
  end

  def publishing_request_internal
    build(:support_request, :set_publishing, :set_internal_only)
  end
end
