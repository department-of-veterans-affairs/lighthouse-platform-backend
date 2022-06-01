class AddKeyToApiCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :api_categories, :key, :string
  end
end
