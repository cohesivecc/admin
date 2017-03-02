class Manager < ActiveRecord::Base
  include ImageUploader[:image]
  cohesive_admin

  validates :name, presence: true
  validates :email, presence: true

  validates :title, inclusion: { in: ["Shift Manager", "Night Manager", "Senior Manager"] }, allow_blank: true

  belongs_to :address, inverse_of: :managers
end
