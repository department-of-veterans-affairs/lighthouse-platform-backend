class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :event_type, null: false
      t.jsonb :content, null: false

      t.timestamps
    end
  end
end
