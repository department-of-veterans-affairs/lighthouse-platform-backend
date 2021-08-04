class MoveOrganizationsToConsumer < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :organization
    add_column :consumers, :organization, :string
  end
end
