class CreateConsumers < ActiveRecord::Migration[6.1]
  def change
    create_table :consumers do |t|
      t.string :description
      t.datetime :tos_accepted_at
      t.integer :tos_version

      t.timestamps
    end
  end
end
