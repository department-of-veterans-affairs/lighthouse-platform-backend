class CreateApisProductionRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :apis_production_requests, id: :uuid do |t|
      t.references :api, null: false, foreign_key: true, type: :bigint
      t.references :production_request, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
