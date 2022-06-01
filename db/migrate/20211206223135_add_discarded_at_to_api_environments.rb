class AddDiscardedAtToApiEnvironments < ActiveRecord::Migration[6.1]
  def change
    add_column :api_environments, :discarded_at, :datetime
    add_index :api_environments, :discarded_at
  end
end
