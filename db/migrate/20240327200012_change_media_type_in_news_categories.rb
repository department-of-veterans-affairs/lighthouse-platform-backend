class ChangeMediaTypeInNewsCategories < ActiveRecord::Migration[7.0]
  def change
    change_column :news_categories, :media, :boolean, using: 'media::boolean', default: false
  end
end
