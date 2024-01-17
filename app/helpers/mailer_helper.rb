# frozen_string_literal: true

module MailerHelper
  # LPB previously supported multiple APIs on sandbox signup,
  # this helper assists with the legacy handling of that setup
  def list_apis(apis)
    apis.map { |api| api.api_metadatum.display_name }.to_sentence
  end

  def get_api_metadata(apis)
    apis.first.api_metadatum
  end

  def get_api_oauth_info(apis)
    JSON.parse(apis.first.api_metadatum.oauth_info)
  end
end
