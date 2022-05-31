class MakeConsumerIdRequired < ActiveRecord::Migration[7.0]
  def change
    change_column_null :consumer_auth_refs, :consumer_id, false
  end
end
