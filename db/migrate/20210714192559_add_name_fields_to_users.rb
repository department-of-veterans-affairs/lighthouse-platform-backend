class AddNameFieldsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :organization, :string
    add_column :users, :role, :string, default: 'user'
  end
end
