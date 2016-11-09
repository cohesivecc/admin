class NestedInput < SimpleForm::Inputs::Base

  def initialize(builder, attribute_name, column, input_type, options = {})
    super
    @options[:label] = false
  end

  def input
    @builder.template.render(partial: 'cohesive_admin/inputs/nested', locals: { options: options} )
    # "$ #{@builder.text_field(attribute_name, merged_input_options)}".html_safe
  end
end
