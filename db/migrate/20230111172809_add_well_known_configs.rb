class AddWellKnownConfigs < ActiveRecord::Migration[7.0]
  def up
    Rake::Task['lpb:seedWellKnownConfigValues'].invoke
  end
end
