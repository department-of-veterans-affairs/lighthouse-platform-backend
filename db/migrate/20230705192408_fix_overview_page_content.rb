class FixOverviewPageContent < ActiveRecord::Migration[7.0]
  def change
    def change
      Rake::Task['lpb:seedOverviewPageContent'].invoke
    end
  end
end
