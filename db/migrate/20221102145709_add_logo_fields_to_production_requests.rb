class AddLogoFieldsToProductionRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :production_requests, :logo_icon, :string
    add_column :production_requests, :logo_large, :string
  end
end
