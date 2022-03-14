class CreateMaliciousUrls < ActiveRecord::Migration[6.1]
  def change
    create_table :malicious_urls do |t|
      t.string :url, null: false

      t.timestamps
    end
    add_index :malicious_urls, :url, unique: true
  end
end
