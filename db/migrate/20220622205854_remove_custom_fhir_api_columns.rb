class RemoveCustomFhirApiColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :api_metadata, :multi_open_api_intro
    remove_column :api_environments, :key
    remove_column :api_environments, :label
    remove_column :api_environments, :api_intro
  end
end
