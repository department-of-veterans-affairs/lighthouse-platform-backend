class CreateApiRefs < ActiveRecord::Migration[6.1]
  def change
    create_table :api_refs do |t|
      t.string :name, unique: true
      t.references :api, foreign_key: true

      t.timestamps
    end
  end
end
