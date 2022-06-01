# frozen_string_literal: true

module MailerHelper
  def list_apis(apis)
    apis.map { |api| api.api_metadatum.display_name }.to_sentence
  end
end
