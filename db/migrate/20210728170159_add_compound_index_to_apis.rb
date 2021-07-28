class AddCompoundIndexToApis < ActiveRecord::Migration[6.1]
  def change
    add_index :apis, [:api_ref, :environment], unique: true
  end
end
