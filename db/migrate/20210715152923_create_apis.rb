class CreateApis < ActiveRecord::Migration[6.1]
  def change
    create_table :apis do |t|
      t.string :name
      t.string :auth_method
      t.string :environment
      t.string :open_api_url
      t.string :base_path
      t.string :service_ref

      t.timestamps
    end
  end
end
