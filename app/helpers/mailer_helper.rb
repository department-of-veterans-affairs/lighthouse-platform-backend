# frozen_string_literal: true

module MailerHelper
  def list_apis(apis)
    api_list = from_db
    apis.split(',').map { |api| api_list[api] }.to_sentence
  end

  private

  def from_db
    {}.tap do |api_builder|
      Api.kept.map { |api| api_builder[api.api_ref.name] = api.api_metadatum.display_name }
    end
  end
end
