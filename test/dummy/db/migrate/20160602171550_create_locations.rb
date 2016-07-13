class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|

      t.string    :slug,      limit: 20

      t.string    :image_id

      t.text      :json_data

      t.timestamps null: false
    end
    add_index :locations, :slug
  end
end
