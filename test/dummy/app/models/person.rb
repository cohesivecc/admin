class Person < ActiveRecord::Base

  cohesive_admin

  VALID_PREFIXES = ["Mr.", "Mrs.", "Ms."]
  belongs_to :job, counter_cache: true
  validates :prefix, presence: true, inclusion: { in: VALID_PREFIXES }



  has_one :address, as: :locatable
  has_one_attached :image
  has_one_attached :file
  has_many_attached :documents


  def to_label
    [self.prefix, " ", self.name.strip].join
  end

end
