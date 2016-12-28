class RefileInput < SimpleForm::Inputs::Base

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

    # grab the Refile attachment_field markup
    html = @builder.label(attribute_name)

    if input_html_options[:help]
      merged_input_options.delete(:help)
    end

    html += template.content_tag(:div, raw(%Q{
      <span>Select File</span>
      #{@builder.attachment_field(attribute_name, merged_input_options)}
      }), class: 'btn')

    html += template.content_tag(:div, raw(%Q{<input class="file-path validate" type="text">}), class: 'file-path-wrapper')

    html = template.content_tag(:div, raw(html), class: 'file-field input-field')

    # show thumbnail
    if @has_file && (attacher = @builder.object.public_send("#{attribute_name}_attacher") rescue nil)

      link_html = template.link_to(
                          template.image_tag(template.attachment_url(@builder.object, attribute_name, :fill, 150, 150)),
                          template.attachment_url(@builder.object, attribute_name),
                          target: '_blank'
                    )

      if @removeable
        # Add the 'remove' button
        link_html += raw(%Q{
          <div>
            #{@builder.input_field("remove_#{attribute_name}", as: :boolean)}
            #{@builder.label("remove_#{attribute_name}", "Remove #{attribute_name.humanize}?")}
          </div>
          })
      end

      link_html = template.content_tag(:div, link_html)
      html += raw(link_html)
    end

    html.html_safe
  end

end
