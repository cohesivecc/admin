class Job < ActiveRecord::Base

  cohesive_admin
  has_many :people
  has_and_belongs_to_many :locations
  scope :sorted, -> { order(:position) }


  def as_json(options={})
    super({ only: [:id, :name] }.merge(options))
  end

end
