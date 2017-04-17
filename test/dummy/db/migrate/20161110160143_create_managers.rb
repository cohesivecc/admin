class CreateManagers < ActiveRecord::Migration[5.0]
  def change
    create_table :managers do |t|
      t.string :name
      t.string :email
      t.string :phone_number
      t.string :title
      t.boolean :active
      t.belongs_to :address

      # Shrine
      t.text :image_data

      t.timestamps null: false
    end
  end
end
