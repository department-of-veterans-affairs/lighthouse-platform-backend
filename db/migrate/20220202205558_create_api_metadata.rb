class CreateApiMetadata < ActiveRecord::Migration[6.1]
  def change
    create_table :api_metadata do |t|
      t.references :api, foreign_key: true
      t.string :description
      t.boolean :enabled_by_default
      t.string :display_name
      t.boolean :open_data
      t.boolean :va_internal_only
      t.datetime :discarded_at

      t.timestamps

      t.index :discarded_at
    end
  end
end
