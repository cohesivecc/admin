class ShrineInput < SimpleForm::Inputs::Base

  attr_reader :has_file

  def initialize(builder, attribute_name, column, input_type, options = {})
    super
    @has_file = @builder.object.send(attribute_name)
    @removeable = options[:removeable] != false
    @options[:label] = false # ||= "Select File"

    if @has_file
      @options[:label].gsub!(/select/i, 'Replace') rescue nil
    end

  end

  def input(wrapper_options=nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    html = @builder.label(attribute_name)

    if input_html_options[:help]
      merged_input_options.delete(:help)
    end

    html += template.content_tag(:div, raw(%Q{
      <span>Select File</span>
      #{@builder.hidden_field(attribute_name, value: @builder.object.send("cached_#{attribute_name}_data"))}
      #{@builder.file_field(attribute_name, merged_input_options)}
      }), class: 'btn')

    html += template.content_tag(:div, raw(%Q{<input class="file-path validate" type="text">}), class: 'file-path-wrapper')

    html = template.content_tag(:div, raw(html), class: 'file-field input-field')

    # show thumbnail if it's an image
    if @has_file

      @img = nil

      obj = @builder.object.send(attribute_name)

      if obj.is_a?(Shrine::UploadedFile) && !(obj.mime_type =~ /image/).nil?
        @img = obj
      elsif obj.is_a?(Hash)
        # find the first image and use it
        obj.each do |k,v|
          if !(v.mime_type =~ /image/).nil?
            @img = v
            break
          end
        end
      end

      if @img || @removeable
        link_html = raw(%Q{
          <div class="row">
            <div class="col s12">
              #{template.link_to(template.image_tag(@img.url, width: 150), @img.url, target: '_blank') if @img}
              <div>
                #{@builder.input_field("remove_#{attribute_name}", as: :boolean) if @removeable}
                #{@builder.label("remove_#{attribute_name}", "Remove #{attribute_name.humanize}?") if @removeable}
              </div>
            </div>
          </div>
          })
        html += raw(link_html)
      end
    end

    html.html_safe
  end

end
