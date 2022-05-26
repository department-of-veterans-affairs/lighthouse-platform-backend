class CreateConsumerAuthRefs < ActiveRecord::Migration[7.0]
  def change
    create_table :consumer_auth_refs do |t|
      t.string :key
      t.string :value
      t.references :consumer, foreign_key: true

      t.timestamps
    end

    remove_column :consumers, :sandbox_gateway_ref, :string
    remove_column :consumers, :sandbox_oauth_ref, :string
    remove_column :consumers, :prod_gateway_ref, :string
    remove_column :consumers, :prod_oauth_ref, :string
  end
end
