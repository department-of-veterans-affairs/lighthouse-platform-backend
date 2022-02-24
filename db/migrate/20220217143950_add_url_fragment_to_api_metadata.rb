class AddUrlFragmentToApiMetadata < ActiveRecord::Migration[6.1]
  def change
    add_column :api_metadata, :url_fragment, :string
  end
end
