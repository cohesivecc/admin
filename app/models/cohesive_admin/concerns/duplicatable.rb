module CohesiveAdmin::Concerns::Duplicatable
  extend ActiveSupport::Concern

  included do
    # any required hooks here
  end

  def admin_duplicatable?
    self.class.admin_duplicatable?
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
