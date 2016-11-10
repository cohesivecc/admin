class Manager < ActiveRecord::Base
  cohesive_admin

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  belongs_to :address
end
