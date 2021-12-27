class AddDiscardedAtToApiRefs < ActiveRecord::Migration[6.1]
  def change
    add_column :api_refs, :discarded_at, :datetime
    add_index :api_refs, :discarded_at
  end
end
