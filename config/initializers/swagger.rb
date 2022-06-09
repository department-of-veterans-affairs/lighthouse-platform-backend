# frozen_string_literal: true

GrapeSwaggerRails.options.url = '/platform-backend/openapi.json'
GrapeSwaggerRails.options.doc_expansion = 'list'
GrapeSwaggerRails.options.hide_url_input = true
GrapeSwaggerRails.options.hide_api_key_input = true

GrapeSwaggerRails.options.before_action do |request|
  GrapeSwaggerRails.options.app_url = request.protocol + request.host_with_port

  if ActiveRecord::Type::Boolean.new.deserialize(Figaro.env.enable_github_auth) && !user_signed_in?
    redirect_to('/platform-backend/users/sign_in')
  end
end
