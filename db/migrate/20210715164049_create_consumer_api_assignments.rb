class CreateConsumerApiAssignments < ActiveRecord::Migration[6.1]
  def change
    create_table :consumer_api_assignments do |t|
      t.references :consumer, null: false, foreign_key: true
      t.references :api, null: false, foreign_key: true
      t.datetime :first_successful_call_at

      t.timestamps
    end
  end
end
