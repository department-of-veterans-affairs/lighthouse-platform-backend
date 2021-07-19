class AddApiRefToApis < ActiveRecord::Migration[6.1]
  def change
    add_column :apis, :api_ref, :string
  end
end
