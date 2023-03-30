class AddUrlSlugToApiCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :api_categories, :url_slug, :string
  end
end
