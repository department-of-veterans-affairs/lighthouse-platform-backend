class AddApiDeactivationInfo < ActiveRecord::Migration[6.1]
  def change
    add_column :api_metadata, :deactivation_info, :jsonb
  end
end
