class Manager < ActiveRecord::Base
  cohesive_admin

  validates :name, presence: true
  validates :email, presence: true

  belongs_to :address, inverse_of: :managers
end
