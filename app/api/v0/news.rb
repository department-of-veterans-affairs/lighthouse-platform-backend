# frozen_string_literal: true

module V0
  class News < V0::Base
    version 'v0'

    resource 'news' do
      desc 'Returns list of news', {
        headers: {
          'Authorization' => {
            required: false
          }
        }
      }
      get '/' do
        news = News
        present news, with: V0:Entities::NewsEntity
      end

      params do
        requires :title, type: String, allow_blank: false
        requires :url, type: String, allow_blank: false
        requires :category, type: String, values: %w[articles digital_media news_releases], allow_blank: false
      end
      post '/' do
        validate_token(Scope.provider_write)
        news_item = News.create(title: params[:title], url: params[:url])
        present news_item, with: V0::Entities::NewsEntity
      end
    end
  end
end
