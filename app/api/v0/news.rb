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
        news = NewsCategory.all
        present news, with: V0::Entities::NewsCategoryEntity
      end

      params do
        requires :callToAction, type: String, allow_blank: false
        requires :description, type: String, allow_blank: false
        requires :media, type: Boolean, allow_blank: false
        requires :title, type: String, allow_blank: false
      end
      post '/categories' do
        news_category = NewsCategory.create(call_to_action: params[:callToAction], description: params[:description],
                                            media: params[:media], title: params[:title])
        present news_category, with: V0::Entities::NewsCategoryEntity
      end

      params do
        requires :category, type: String, allow_blank: false
        requires :date, type: String, allow_blank: false
        optional :source, type: String, allow_blank: false
        requires :title, type: String, allow_blank: false
        requires :url, type: String, allow_blank: false
      end
      post '/categories/:category/items' do
        news_category = NewsCategory.find_by(title: params[:category])
        news_item = if news_category.present? && news_category.title == 'releases'
                      NewsItem.create(news_category_id: news_category.id, date: params[:date],
                                      title: params[:title], url: params[:url])
                    else
                      NewsItem.create(news_category_id: news_category.id, date: params[:date], source: params[:source],
                                      title: params[:title], url: params[:url])
                    end
        present news_item, with: V0::Entities::NewsItemEntity
      end

      params do
        requires :category, type: String, allow_blank: false
        requires :item, type: String, allow_blank: false
        requires :date, type: String, allow_blank: false
        optional :source, type: String, allow_blank: false
        requires :title, type: String, allow_blank: false
        requires :url, type: String, allow_blank: false
      end
      put '/categories/:category/items/:item' do
        news_category = NewsCategory.find_by(title: params[:category])
        news_item = NewsItem.find_by(title: params[:item])
        if news_category.present? && news_category.title == 'releases'
          news_item.update(news_category_id: news_category.id, date: params[:date],
                           title: params[:title], url: params[:url])
        else
          news_item.update(news_category_id: news_category.id, date: params[:date], source: params[:source],
                           title: params[:title], url: params[:url])
        end
        present news_item, with: V0::Entities::NewsItemEntity
      end
    end
  end
end
