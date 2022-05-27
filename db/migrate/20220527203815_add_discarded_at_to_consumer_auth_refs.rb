class AddDiscardedAtToConsumerAuthRefs < ActiveRecord::Migration[7.0]
  def change
    add_column :consumer_auth_refs, :discarded_at, :datetime
    add_index :consumer_auth_refs, :discarded_at
  end
end
