# frozen_string_literal: true

GrapeSwaggerRails.options.url = '/platform-backend/openapi.json'
GrapeSwaggerRails.options.doc_expansion = 'list'
GrapeSwaggerRails.options.hide_url_input = true
GrapeSwaggerRails.options.hide_api_key_input = true

GrapeSwaggerRails.options.before_action do |request|
  GrapeSwaggerRails.options.app_url = request.protocol + request.host_with_port

  redirect_to('/platform-backend') if Figaro.env.enable_github_auth.present? && !user_signed_in?
end
