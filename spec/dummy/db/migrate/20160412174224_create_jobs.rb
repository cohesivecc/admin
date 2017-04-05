class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string    :name

      t.integer   :position,    default: 0
      t.integer   :people_count, default: 0

      t.timestamps null: false
    end
  end
end
