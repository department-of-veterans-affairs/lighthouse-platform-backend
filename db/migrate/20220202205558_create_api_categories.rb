class CreateApiCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :api_categories do |t|
      t.string :name
      t.datetime :discarded_at

      t.timestamps

      t.index :discarded_at
    end
  end
end
