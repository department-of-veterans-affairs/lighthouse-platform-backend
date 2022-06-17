class ChangeVaInternalOnlyToEnum < ActiveRecord::Migration[7.0]
  def up
    remove_column :api_metadata, :va_internal_only
    execute <<-SQL
      CREATE TYPE va_internal_type AS ENUM ('StrictlyInternal', 'AdditionalDetails', 'FlagOnly');
    SQL
    add_column :api_metadata, :va_internal_only, :va_internal_type
  end

  def down
    remove_column :api_metadata, :va_internal_only
    execute <<-SQL
      DROP TYPE va_internal_type;
    SQL
    add_column :api_metadata, :va_internal_only, :boolean
  end
end
