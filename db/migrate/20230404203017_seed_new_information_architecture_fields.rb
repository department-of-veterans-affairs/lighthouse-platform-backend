class SeedNewInformationArchitectureFields < ActiveRecord::Migration[7.0]
  def change
    Rake::Task['lpb:seedIAFieldValues'].invoke
  end
end
