class CreateApiReleaseNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :api_release_notes do |t|
      t.references :api_metadatum, foreign_key: true
      t.datetime :date
      t.string :content
      t.datetime :discarded_at

      t.timestamps

      t.index :discarded_at
    end
  end
end
