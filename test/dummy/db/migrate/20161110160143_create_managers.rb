class CreateManagers < ActiveRecord::Migration
  def change
    create_table :managers do |t|
      t.string :name
      t.string :email
      t.string :phone_number
      t.belongs_to :address

      t.timestamps null: false
    end
  end
end
