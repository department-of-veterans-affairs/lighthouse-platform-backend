class AddMultiApiMetadataToApiEnvironments < ActiveRecord::Migration[6.1]
  def change
    add_column :api_environments, :key, :string
    add_column :api_environments, :label, :string
    add_column :api_environments, :api_intro, :string
  end
end
