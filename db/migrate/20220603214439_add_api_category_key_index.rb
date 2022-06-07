class AddApiCategoryKeyIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :api_categories, :key, unique: true
  end
end
