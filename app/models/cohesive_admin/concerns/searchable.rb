module CohesiveAdmin::Concerns::Searchable
  extend ActiveSupport::Concern

  def admin_searchable?
    self.class.admin_searchable?
  end
	
	class_methods do
		
		def admin_searchable?
			false
		end
		
		def admin_searchable
      class_eval do
        attr_accessor :ca_search
				define_singleton_method(:admin_searchable?) do
					true
				end
      end
		end
	end
end
