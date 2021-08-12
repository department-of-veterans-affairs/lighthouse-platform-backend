class RemoveApiRefUniqueIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :apis, [:api_ref, :environment], unique: true
  end
end
