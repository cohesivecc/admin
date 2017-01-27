class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|

      t.string    :street
      t.string    :city
      t.string    :state
      t.string    :zip
      t.text      :description

      t.integer   :position,  default: 0

      t.belongs_to :locatable, polymorphic: true

      t.timestamps null: false
    end
  end
end
