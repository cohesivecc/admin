class PolymorphicInput < SimpleForm::Inputs::Base


  def initialize(builder, attribute_name, column, input_type, options = {})
    super
    @options[:label] = false
  end

  def input(wrapper_options=nil)
    object  = @builder.object
    klass   = object.class

    r = klass.reflections[attribute_name.to_s]

    if r.polymorphic?

      # TODO: handle has_many etc.
      type_attribute  = r.foreign_type
      key_attribute   = r.foreign_key

      # if validation is set up on model to limit inclusion of type_attribute, we can filter our list
      whitelist = nil
      klass.validators_on(type_attribute).each do |v|
        if v.kind == :inclusion && v.options[:in].is_a?(Array)
          whitelist = v.options[:in]
        end
      end
      type_options = CohesiveAdmin::Dashboard.managed_models.collect {|m| whitelist.nil? || whitelist.include?(m.name) ? [m.admin_display_name, m.name] : nil }.compact

      type_input = @builder.input(type_attribute, collection: type_options, input_html: { data: { 'polymorphic-type' => attribute_name, 'initial' => object.send(type_attribute) }})

      key_input = @builder.input(key_attribute, collection: [], input_html: { data: { 'polymorphic-key' => attribute_name, 'initial' => object.send(key_attribute) }})

      html = %Q{
        <div class="row">
          <div class="col m6">#{type_input}</div>
          <div class="col m6">#{key_input}</div>
        </div>
      }

      html.html_safe

    end

  end

end
