class AddAuthServerAccessKeyColumnToApis < ActiveRecord::Migration[6.1]
  def change
    add_column :apis, :auth_server_access_key, :string
  end
end
