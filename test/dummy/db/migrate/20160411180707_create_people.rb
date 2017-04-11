class CreatePeople < ActiveRecord::Migration[5.0]
  def change
    create_table :people do |t|
      t.string :prefix
      t.string :name
      t.string :email

      t.text    :bio

      t.boolean :active, default: true

      t.belongs_to :job

      t.timestamps null: false
    end
  end
end
