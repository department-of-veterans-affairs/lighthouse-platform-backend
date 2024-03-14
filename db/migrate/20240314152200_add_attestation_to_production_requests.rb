class AddAttestationToProductionRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :production_requests, :attestation_checked, :boolean
  end
end
