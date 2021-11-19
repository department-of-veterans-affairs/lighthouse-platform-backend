class CreateEnvironments < ActiveRecord::Migration[6.1]
  def change
    create_table :environments do |t|
      t.string :name, unique: true

      t.timestamps
    end
  end
end
