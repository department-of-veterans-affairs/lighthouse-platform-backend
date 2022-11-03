class AddVeteranRedirectToApiMetadata < ActiveRecord::Migration[7.0]
  def change
    add_column :api_metadata, :veteran_redirect_link_url, :string
    add_column :api_metadata, :veteran_redirect_link_text, :string
    add_column :api_metadata, :veteran_redirect_message, :string
  end
end
