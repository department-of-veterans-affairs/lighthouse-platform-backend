class AddRestrictedAccessDetailsToApiMetadata < ActiveRecord::Migration[7.0]
  def change
    add_column :api_metadata, :restricted_access_details, :text
  end
end
