class AddNameFieldsToConsumers < ActiveRecord::Migration[6.1]
  def change
    add_column :consumers, :sandbox_gateway_ref, :string
    add_column :consumers, :sandbox_oauth_ref, :string
    add_column :consumers, :prod_gateway_ref, :string
    add_column :consumers, :prod_oauth_ref, :string
  end
end
