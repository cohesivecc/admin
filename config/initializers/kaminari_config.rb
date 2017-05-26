Kaminari.configure do |config|
  config.default_per_page = 10
  # config.max_per_page = nil
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
end


module CohesiveAdmin
  module KaminariResourceURLs

    # Because we share a controller across multiple resources, Kaminari's default url_for won't work.
    # We override this method to parse the class name out of @params and build actual resource URLs
    def page_url_for(page)
      page_params = @params.symbolize_keys.merge(@param_name.to_sym => (page <= 1 ? nil : page), :only_path => true)

      # If this is a resource URL, we need to intercept
      if page_params.has_key?(:class_name)
        klass = (page_params.delete(:class_name).constantize rescue nil)
        page_params.delete(:action) if page_params[:action] == 'index'
        page_params = [klass, page_params]
      end
      @template.url_for page_params
    end

    # # For Kaminari 1.0 (untested)
    #
    #
    # def page_url_for(page)
    #   if @params.has_key?(:class_name)
    #     page_params = params_for(page)
    #
    #     klass = (page_params.delete(:class_name).constantize rescue nil)
    #     page_params.delete(:action) if page_params[:action] == 'index'
    #     @template.url_for [klass, page_params]
    #   else
    #     super(page)
    #   end
    # end

  end
end
Kaminari::Helpers::Tag.send(:prepend, CohesiveAdmin::KaminariResourceURLs)
