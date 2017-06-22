module CohesiveAdmin::Concerns::Sortable
  extend ActiveSupport::Concern

  def admin_sortable?
    self.class.admin_sortable?
  end

	class_methods do

    def admin_sortable?
      false
    end

    def admin_sortable(args)
      @sort_column = args
			
      class_eval do

        scope :admin_sorted, -> { order(self.admin_sort_column) }
				
				define_method(:admin_sort_column) do
					self.class.admin_sort_column
				end
				

				define_singleton_method(:admin_sortable?) do
					true
				end
				
				define_singleton_method(:admin_sort_column) do
					@sort_column
				end
				
				define_singleton_method(:admin_order_by) do
					@sort_column
				end

      end

    end

  end

end
