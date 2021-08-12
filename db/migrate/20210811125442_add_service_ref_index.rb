class AddServiceRefIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :apis, :service_ref, unique: true
  end
end
