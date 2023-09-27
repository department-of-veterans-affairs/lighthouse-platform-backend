# frozen_string_literal: true

class HomeController < ApplicationController
  def index; end

  # rubocop:disable Metrics/MethodLength
  def sitemap
    urls = SitemapUrl.all.pluck(:url)
    Api.joins(:api_metadatum).each do |api|
      urls.push("/explore/api/#{api.api_metadatum[:url_slug]}")
      oauth = JSON.parse(api.api_metadatum[:oauth_info]) if api.api_metadatum.oauth_info.present?
      if oauth.present?
        urls.push("/explore/api/#{api.api_metadatum[:url_slug]}/authorization-code") if oauth['acgInfo'].present?
        urls.push("/explore/api/#{api.api_metadatum[:url_slug]}/client-credentials") if oauth['ccgInfo'].present?
      end
      urls.push("/explore/api/#{api.api_metadatum[:url_slug]}/release-notes")
      unless api.api_metadatum.block_sandbox_form?
        urls.push("/explore/api/#{api.api_metadatum[:url_slug]}/sandbox-access")
      end
    end
    render :sitemap, content_type: 'text/xml', locals: { urls: urls }
  end
  # rubocop:enable Metrics/MethodLength
end
