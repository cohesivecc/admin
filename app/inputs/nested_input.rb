class NestedInput < SimpleForm::Inputs::Base

  def initialize(builder, attribute_name, column, input_type, options = {})
    super
    @options[:label] = false
    @field = @builder.object.class.admin_fields[attribute_name]
    @reflection = @field[:reflection]
  end

  def input(wrapper_options)
    @builder.template.render(partial: 'cohesive_admin/inputs/nested/input', locals: {
                                                                                f: @builder,
                                                                                klass: @reflection.klass,
                                                                                parent_klass: @builder.object.class,
                                                                                attribute_name: attribute_name,
                                                                                singular: [:belongs_to, :has_one].include?(@reflection.macro)
                                                                              })
  end
end
