class AddStealthLaunchedField < ActiveRecord::Migration[7.0]
  def change
    add_column :api_metadata, :is_stealth_launched, :boolean, default: false
  end
end
