
# Custom SimpleForm input used for Froala rich text editor

class CodeInput < SimpleForm::Inputs::Base


  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    @builder.text_area(attribute_name, merged_input_options).html_safe
  end
  def input_html_options
    super.merge({class: 'code'})
  end

end
