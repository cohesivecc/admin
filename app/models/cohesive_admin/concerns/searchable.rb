module CohesiveAdmin::Concerns::Searchable
  extend ActiveSupport::Concern

  included do
  end

  def admin_searchable?
    self.class.admin_searchable?
  end

  module ClassMethods

    def admin_searchable?
      false
    end

    def admin_searchable
      class_eval do
        attr_accessor :ca_search

        class << self
          def admin_searchable?
            true
          end
        end
      end
    end

  end
end