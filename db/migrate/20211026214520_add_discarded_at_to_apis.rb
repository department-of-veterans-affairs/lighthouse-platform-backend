class AddDiscardedAtToApis < ActiveRecord::Migration[6.1]
  def change
    add_column :apis, :discarded_at, :datetime
    add_index :apis, :discarded_at
  end
end
