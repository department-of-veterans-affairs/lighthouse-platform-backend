class ConsumerApisToUseApiEnvironments < ActiveRecord::Migration[6.1]
  def change
    remove_column :consumer_api_assignments, :environment_id, :integer
    add_reference :consumer_api_assignments, :api_environment, index: true
  end
end