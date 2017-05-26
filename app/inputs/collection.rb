class CollectionInput < SimpleForm::Inputs::Base


  def initialize(builder, attribute_name, column, input_type, options = {})
    super
    @options[:label] = false
  end

  def input(wrapper_options=nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    @builder.input(attribute_name, merged_input_options).html_safe
  end

  def input_html_options
    collection = []
    @builder.object.class.validators_on(attribute_name).collect do |v|
      if v.kind == :inclusion && v.options[:in].is_a?(Array)
        collection << v.options[:in]
      end
    end
    super.merge({ collection: collection.flatten })
  end


end
