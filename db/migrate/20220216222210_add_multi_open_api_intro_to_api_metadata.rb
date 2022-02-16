class AddMultiOpenApiIntroToApiMetadata < ActiveRecord::Migration[6.1]
  def change
    add_column :api_metadata, :multi_open_api_intro, :string
  end
end
