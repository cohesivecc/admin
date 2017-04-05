# This migration comes from cohesive_admin (originally 20160408165151)
class CreateCohesiveAdminUsers < ActiveRecord::Migration
  def change
    create_table :cohesive_admin_users do |t|
      t.string :name,             limit: 40
      t.string :email,            limit: 80
      t.string :password_digest
      t.string :user_type
      t.timestamps null: false
    end
    add_index :cohesive_admin_users, :email
  end
end
