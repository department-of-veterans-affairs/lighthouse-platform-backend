class AddDiscardedAtToEnvironments < ActiveRecord::Migration[6.1]
  def change
    add_column :environments, :discarded_at, :datetime
    add_index :environments, :discarded_at
  end
end
