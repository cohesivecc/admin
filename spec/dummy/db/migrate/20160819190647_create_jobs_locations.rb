class CreateJobsLocations < ActiveRecord::Migration
  def change
    create_table :jobs_locations, id: false do |t|
      t.references :job
      t.references :location
    end
    add_index :jobs_locations, [:job_id, :location_id]
  end
end
