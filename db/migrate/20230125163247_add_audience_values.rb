class AddAudienceValues < ActiveRecord::Migration[7.0]
  def up
    Rake::Task['lpb:seedAudienceValues'].invoke
  end
end
