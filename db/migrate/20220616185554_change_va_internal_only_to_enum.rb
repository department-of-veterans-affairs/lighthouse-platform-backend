class ChangeVaInternalOnlyToEnum < ActiveRecord::Migration[7.0]
  def change
    remove_column :api_metadata, :va_internal_only
    add_column :api_metadata, :va_internal_only, :string
  end
end
