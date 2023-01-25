class AddAudienceValues < ActiveRecord::Migration[7.0]
  def up
    Rake::Task['aud_values:seedAudienceValues'].invoke
  end
end
