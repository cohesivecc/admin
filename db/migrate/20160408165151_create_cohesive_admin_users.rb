class CreateCohesiveAdminUsers < ActiveRecord::Migration
  def change
    create_table :cohesive_admin_users do |t|
      t.string :name,             limit: 40
      t.string :email,            limit: 80
      t.string :password_digest
      t.timestamps null: false
    end
    add_index :cohesive_admin_users, :email
  end
end
