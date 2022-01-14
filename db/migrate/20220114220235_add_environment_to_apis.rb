class AddEnvironmentToApis < ActiveRecord::Migration[6.1]
  def change
    add_reference :apis, :environment, index: true
  end
end
