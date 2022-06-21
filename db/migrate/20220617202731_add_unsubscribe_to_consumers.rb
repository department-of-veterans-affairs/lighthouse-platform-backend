class AddUnsubscribeToConsumers < ActiveRecord::Migration[7.0]
  def change
    add_column :consumers, :unsubscribe, :boolean, default: false
  end
end
