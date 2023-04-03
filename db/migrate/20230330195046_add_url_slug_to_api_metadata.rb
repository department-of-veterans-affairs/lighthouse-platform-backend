class AddUrlSlugToApiMetadata < ActiveRecord::Migration[7.0]
  def change
    add_column :api_metadata, :url_slug, :string
  end
end
