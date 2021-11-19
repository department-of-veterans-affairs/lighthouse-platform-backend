class CreateApiEnvironments < ActiveRecord::Migration[6.1]
  def change
    create_table :api_environments do |t|
      t.references :api, foreign_key: true
      t.references :environment, foreign_key: true
      t.string :metadata_url

      t.timestamps
    end
  end
end
