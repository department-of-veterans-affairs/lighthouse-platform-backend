class ConvertFieldsWithNewLines < ActiveRecord::Migration[7.0]
  def up
    change_column :api_categories, :overview, :text
    change_column :api_categories, :quickstart, :text
    change_column :api_release_notes, :content, :text
  end

  def down
    change_column :api_categories, :overview, :string
    change_column :api_categories, :quickstart, :string
    change_column :api_release_notes, :content, :string
  end
end
