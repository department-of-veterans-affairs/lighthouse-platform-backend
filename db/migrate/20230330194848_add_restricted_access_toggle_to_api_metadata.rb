class AddRestrictedAccessToggleToApiMetadata < ActiveRecord::Migration[7.0]
  def change
    add_column :api_metadata, :restricted_access_toggle, :boolean
  end
end
