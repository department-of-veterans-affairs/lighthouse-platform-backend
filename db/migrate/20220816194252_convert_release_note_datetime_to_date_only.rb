class ConvertReleaseNoteDatetimeToDateOnly < ActiveRecord::Migration[7.0]
  def up
    change_column :api_release_notes, :date, :date
  end

  def down
    change_column :api_release_notes, :date, :datetime
  end
end
