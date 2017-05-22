module CohesiveAdmin::Concerns::Sortable
  extend ActiveSupport::Concern

  included do
    # any required hooks here
  end

  def admin_sortable?
    self.class.admin_sortable?
  end

  module ClassMethods

    def admin_sortable?
      false
    end

    def admin_sortable(args)
				
      @sort_column = args

      class_eval do

        scope :admin_sorted, -> { order(self.admin_sort_column) }

        def admin_sort_column
          self.class.admin_sort_column
        end

        class << self

          def admin_sort_column
            @sort_column
          end
					
					def admin_order_by
						@sort_column
					end

          def admin_sortable?
            true
          end

        end

      end

    end

  end

end
