class CreateProductionRequestContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :production_request_contacts, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :type
      t.references :production_request, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
