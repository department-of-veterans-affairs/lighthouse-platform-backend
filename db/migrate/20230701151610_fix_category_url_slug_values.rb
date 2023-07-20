class FixCategoryUrlSlugValues < ActiveRecord::Migration[7.0]
  def change
    Rake::Task['lpb:fixCategoryUrlSlugValues'].invoke
  end
end
