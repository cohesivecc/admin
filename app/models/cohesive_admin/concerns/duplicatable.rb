module CohesiveAdmin::Concerns::Duplicatable
  extend ActiveSupport::Concern

  included do
    # any required hooks here
  end

  def admin_duplicatable?
    self.class.admin_duplicatable?
  end

  def duplicate_record(record_id, parent_klass=nil, parent_id=nil)
    fields = self.class.admin_fields
    original_template = self.class.find(record_id)
    new_record = original_template.dup
    if(parent_id && parent_klass)
      new_record["#{parent_klass.to_s.downcase.underscore}_id"] = parent_id
    end
    new_record.save
    fields.each do |field|
      if field[1] && field[1].with_indifferent_access[:type].to_sym == :association
        child_fields = original_template.try(field[0])
        next if original_template.class.reflect_on_association(field[0].to_sym).class == ActiveRecord::Reflection::BelongsToReflection
        child_fields.each do |child|
          child.duplicate_record(child.id, new_record.class, new_record.id)
        end
      end
    end
    return new_record.id
  end

  module ClassMethods

    def admin_duplicatable?
      false
    end

    def admin_duplicatable(args)

      class_eval do

        class << self

          def admin_duplicatable?
            true
          end

        end

      end

    end

  end

end
