class AddSandboxFormColumnToApiMetadatum < ActiveRecord::Migration[7.0]
  def change
    add_column :api_metadata, :block_sandbox_form, :boolean, :default => false
  end
end
