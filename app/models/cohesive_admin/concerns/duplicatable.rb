module CohesiveAdmin::Concerns::Duplicatable
  extend ActiveSupport::Concern

  def admin_duplicatable?
    self.class.admin_duplicatable?
  end
	
	class_methods do
		
    def admin_duplicatable?
      false
    end
		
		def admin_duplicatable
      class_eval do
				define_singleton_method(:admin_duplicatable?) do
					true
				end
      end
		end
		
	end

end
