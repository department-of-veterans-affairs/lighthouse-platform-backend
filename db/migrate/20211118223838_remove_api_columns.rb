class RemoveApiColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :apis, :auth_method 
    remove_column :apis, :environment 
    remove_column :apis, :open_api_url 
    remove_column :apis, :base_path 
    remove_column :apis, :service_ref 
    remove_column :apis, :version 
    remove_column :apis, :api_ref 
  end
end
