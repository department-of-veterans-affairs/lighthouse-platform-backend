class AddApiNameIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :apis, :name, unique: true
  end
end
