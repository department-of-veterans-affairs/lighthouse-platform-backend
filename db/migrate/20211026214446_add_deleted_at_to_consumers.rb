class AddDeletedAtToConsumers < ActiveRecord::Migration[6.1]
  def change
    add_column :consumers, :deleted_at, :datetime
    add_index :consumers, :deleted_at
  end
end
