class DefaultStealthLaunchedToTrue < ActiveRecord::Migration[7.0]
  def up
    change_column :api_metadata, :is_stealth_launched, :boolean, default: true
  end

  def down
    change_column :api_metadata, :is_stealth_launched, :boolean, default: false
  end
end
