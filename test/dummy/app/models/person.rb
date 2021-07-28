class Person < ActiveRecord::Base

  cohesive_admin

  VALID_PREFIXES = ["Mr.", "Mrs.", "Ms."]
  belongs_to :job, counter_cache: true
  validates :prefix, presence: true, inclusion: { in: VALID_PREFIXES }
  validates :image, attached: true, content_type: ['image/png','image/jpeg']
  after_validation :reasigned_attachment

  has_one :address, as: :locatable
  has_one_attached :image
  has_one_attached :file
  has_many_attached :documents


  def to_label
    [self.prefix, " ", self.name.strip].join
  end

  def reasigned_attachment
    if self.errors[:image]
      #ActiveStorage::Attachment.find_signed(self.image.signed_id)
      # self.image = self.image.signed_id
      # Rails.logger.info ActiveStorage::Blob.find_signed!(self.image.signed_id,purpose: :blob_id)
      # ActiveStorage::Attachment.find_signed('eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBZ3ciLCJleHAiOm51bGwsInB1ciI6ImJsb2JfaWQifX0=--92184f0b84e3c340e29351325e2680b50f846b94')
    end
  end 
  

end
