class AddAclAndApiRefToApis < ActiveRecord::Migration[6.1]
  def change
    add_column :apis, :acl, :string
  end
end
