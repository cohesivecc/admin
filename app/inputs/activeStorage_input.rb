class ActiveStorageInput < SimpleForm::Inputs::Base

  attr_reader :has_file

  def initialize(builder, attribute_name, column, input_type, options = {})
    super


    @has_file = builder.object.send(attribute_name).attached?
    #has_file = @person.image.attached
    #has_file = url_for(@person.image)
    @removeable = options[:removeable] != false
    @options[:label] = false # ||= "Select File"
    @field = @builder.object.class.admin_fields[attribute_name]
    @multiple = @field[:multiple]

    if @has_file
      @options[:label].gsub!(/select/i, 'Replace') rescue nil
    end

  end

  def input(wrapper_options=nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    merged_input_options = merge_wrapper_options(merged_input_options, {:multiple=>@multiple})
    html = @builder.label(attribute_name)

    if input_html_options[:help]
      merged_input_options.delete(:help)
    end

    html += template.content_tag(:div, raw(%Q{
      <span>Select File</span>
      #{@builder.file_field(attribute_name, merged_input_options)}
      }), class: 'btn')

    html += template.content_tag(:div, raw(%Q{<input class="file-path validate" type="text">}), class: 'file-path-wrapper')

    html = template.content_tag(:div, raw(html), class: 'file-field input-field')

    if @has_file

      obj = @builder.object.send(attribute_name)
      if  !obj.respond_to?('each')
          html += attached_file_html(obj)
      else
        (obj).each do |attachment|
          html += attached_file_html(attachment)
        end
      end
    end

    html.html_safe
  end

  def attached_file_html(atttachment)
    returnHtml = ''
    file_path = Rails.application.routes.url_helpers.rails_blob_path(atttachment, only_path: true)
    content = ''
    if atttachment.image?
      thumb_path = Rails.application.routes.url_helpers.rails_representation_url(atttachment.variant(resize_to_limit:[100,100]), only_path: true)
      content = template.image_tag(thumb_path, width: 100)  
    else
      content = atttachment.filename
    end

    returnHtml = raw(%Q{
        <div class="col s4 attachment">
          #{template.link_to(content, file_path, target: '_blank')}
          <label for="remove-#{atttachment.id}"><input class="boolean optional" type="checkbox" value="#{atttachment.id}"  name="removeAttachment[]" id="remove-#{atttachment.id}"><span>Remove</span></label>
        </div>
        #{}
      })
      
    return returnHtml
  end

end
