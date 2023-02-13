class CreateNews < ActiveRecord::Migration[7.0]
  def change
    create_table :news do |t|
      t.string :title
      t.string :url
      t.string :category

      t.timestamps
    end
  end
end
