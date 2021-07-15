class AddUserToConsumers < ActiveRecord::Migration[6.1]
  def change
    add_reference :consumers, :user, null: false, foreign_key: true
  end
end
