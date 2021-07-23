class AddVersionToApis < ActiveRecord::Migration[6.1]
  def change
    add_column :apis, :version, :string
  end
end
