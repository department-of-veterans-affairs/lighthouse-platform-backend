class AddOverviewPageContentToApiMetadata < ActiveRecord::Migration[7.0]
  def change
    add_column :api_metadata, :overview_page_content, :text
  end
end
