class UpdateApiDescriptions < ActiveRecord::Migration[7.0]
  def change
    Rake::Task['lpb:updateApiDescriptions'].invoke
  end
end
