class CreateBackgroundJobEnforcers < ActiveRecord::Migration[7.0]
  def change
    create_table :background_job_enforcers do |t|
      t.string :job_type
      t.date :date

      t.timestamps
    end
    add_index :background_job_enforcers, :date, unique: true
  end
end
