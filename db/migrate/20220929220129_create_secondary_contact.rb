class CreateSecondaryContact < ActiveRecord::Migration[7.0]
  def change
    create_table :secondary_contacts, id: :uuid do |t|
      t.references :production_request, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
  end
end
