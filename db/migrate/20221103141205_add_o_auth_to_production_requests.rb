class AddOAuthToProductionRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :production_requests, :oauth_application_type, :string
    add_column :production_requests, :oauth_public_key, :jsonb
    add_column :production_requests, :oauth_redirect_uri, :string
  end
end
