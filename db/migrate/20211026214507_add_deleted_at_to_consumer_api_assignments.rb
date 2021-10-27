class AddDeletedAtToConsumerApiAssignments < ActiveRecord::Migration[6.1]
  def change
    add_column :consumer_api_assignments, :deleted_at, :datetime
    add_index :consumer_api_assignments, :deleted_at
  end
end
