# frozen_string_literal: true

class HomeController < ApplicationController
  def index; end

  def sitemap;
    static_urls = SitemapUrl.all.pluck(:url)
    apis = Api.includes(:api_metadatum)
    apis.each do |api|
      if api.api_metadatum
        static_urls.push("/explore/api/#{api.api_metadatum[:url_slug]}")
        if api.api_metadatum.oauth_info.present?
          oauth = JSON.parse(api.api_metadatum[:oauth_info])
          if oauth['acgInfo'].present?
            static_urls.push("/explore/api/#{api.api_metadatum[:url_slug]}/authorization-code")
          end
          if oauth['ccgInfo'].present?
            static_urls.push("/explore/api/#{api.api_metadatum[:url_slug]}/client-credentials")
          end
        end
        static_urls.push("/explore/api/#{api.api_metadatum[:url_slug]}/release-notes")
        unless api.api_metadatum.block_sandbox_form
          static_urls.push("/explore/api/#{api.api_metadatum[:url_slug]}/sandbox-access")
        end
      end
    end

    static_urls.sort
    render :sitemap, :content_type => 'text/xml', :locals => { :urls => static_urls }
  end
end
