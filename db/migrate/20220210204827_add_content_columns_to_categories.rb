class AddContentColumnsToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :api_categories, :consumer_docs_link_text, :string
    add_column :api_categories, :short_description, :string
    add_column :api_categories, :quickstart, :string
    add_column :api_categories, :veteran_redirect_link_url, :string
    add_column :api_categories, :veteran_redirect_link_text, :string
    add_column :api_categories, :veteran_redirect_message, :string
    add_column :api_categories, :overview, :string
  end
end
