class CreateProductionRequestsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :production_requests_users, id: :uuid do |t|
      t.references :production_request, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.string :type

      t.timestamps
    end
  end
end
