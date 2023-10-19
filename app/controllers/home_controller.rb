# frozen_string_literal: true

class HomeController < ApplicationController
  def index; end

  # rubocop:disable Metrics/MethodLength
  def sitemap
    urls = SitemapUrl.all.pluck(:url)
    Api.joins(:api_metadatum).each do |api|
      if api.api_metadatum.deactivation_info.blank? && !api.api_metadatum.is_stealth_launched?
        urls.push("/explore/api/#{api.api_metadatum.url_slug}")
        suffixes = url_suffixes api
        suffixes.each do |suffix|
          urls.push("/explore/api/#{api.api_metadatum.url_slug}/#{suffix}")
        end
      end
    end
    render :sitemap, content_type: 'text/xml', locals: { urls: urls }
  end
  # rubocop:enable Metrics/MethodLength

  private

  def url_suffixes(api)
    suffixes = []
    suffixes.push('docs')
    oauth = JSON.parse(api.api_metadatum.oauth_info) if api.api_metadatum.oauth_info.present?
    if oauth.present?
      suffixes.push('authorization-code') if oauth['acgInfo'].present?
      suffixes.push('client-credentials') if oauth['ccgInfo'].present?
    end
    suffixes.push('release-notes')
    suffixes.push('sandbox-access') unless api.api_metadatum.block_sandbox_form?

    suffixes
  end
end
