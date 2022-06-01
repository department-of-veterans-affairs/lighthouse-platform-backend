class SwitchEnvironmentsWithApis < ActiveRecord::Migration[6.1]
  def change
    remove_column :consumer_api_assignments, :api_id
    add_reference :consumer_api_assignments, :environment, index: true
  end
end