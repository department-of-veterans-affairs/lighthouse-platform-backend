class AddCompanyAddressToProductionRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :production_requests, :address_line_1, :string
    add_column :production_requests, :address_line_2, :string
    add_column :production_requests, :address_line_3, :string
    add_column :production_requests, :city, :string
    add_column :production_requests, :country, :string
    add_column :production_requests, :state, :string
    add_column :production_requests, :zip_code_5, :string
  end
end
