class AddDeletedAtToApis < ActiveRecord::Migration[6.1]
  def change
    add_column :apis, :deleted_at, :datetime
    add_index :apis, :deleted_at
  end
end
