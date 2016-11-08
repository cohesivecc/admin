class Location < ActiveRecord::Base

  cohesive_admin({ finder: :find_by_slug })

  # has_one :address, inverse_of: :location
  has_many :addresses, as: :locatable
  has_and_belongs_to_many :jobs

  attachment :image, type: :image

  accepts_nested_attributes_for :addresses, allow_destroy: true

  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9]*\Z/i, message: "must only include letters and numbers" }

  def to_param
    slug
  end

  def to_label
    %Q{#{id} - #{slug}}
  end

end
