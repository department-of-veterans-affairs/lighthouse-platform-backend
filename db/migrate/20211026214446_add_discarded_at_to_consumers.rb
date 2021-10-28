class AddDiscardedAtToConsumers < ActiveRecord::Migration[6.1]
  def change
    add_column :consumers, :discarded_at, :datetime
    add_index :consumers, :discarded_at
  end
end
