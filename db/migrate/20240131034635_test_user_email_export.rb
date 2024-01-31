class TestUserEmailExport < ActiveRecord::Migration[7.0]
  def change
    create_table :test_user_emails do |t|
      t.text :email, null: false, :unique => true
      t.boolean :claims, default: false, null: false
      t.boolean :clinicalHealth, default: false, null: false
      t.boolean :communityCare, default: false, null: false
      t.boolean :health, default: false, null: false
      t.boolean :verification, default: false, null: false
    end

    add_index :test_user_emails, :email, unique: true
  end
end
