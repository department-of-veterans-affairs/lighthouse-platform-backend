class CreateNews < ActiveRecord::Migration[7.0]
  def change
    create_table :news do |t|
      t.string :call_to_action
      t.string :description
      t.string :media
      t.string :title
    end

    create_table :news_items do |t|
      t.references :news, foreign_key: true
      t.string :date
      t.string :source
      t.string :title
      t.string :url
      t.timestamps
    end
  end
end
