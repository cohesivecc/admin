

class window.NestedInput

  @initialize: () ->
    if(typeof(Handlebars) != 'undefined') # Handlebars is required
      $('[data-nested]').each( () ->
        if($(@).data('nested') == '')
          $(@).data('nested', new NestedInput($(@)))
      )

  constructor: (@ele) ->

    @t        = $(@ele).children('[data-nested-template]')
    @key      = @t.data('nested-template')
    @t_html   = @t.remove().html()

    ind_regex = new RegExp("__"+@key+"_index__", 'g')
    obj_regex = new RegExp("__"+@key+"_object_id__", 'g')

    @t_html   = @t_html.replace(obj_regex, "{{"+@key+"_object_id}}").replace(ind_regex, "{{"+@key+"_index}}")


    # @template = Handlebars.compile($(@ele).children('[data-nested-template]').remove().html())
    @template = Handlebars.compile(@t_html)
    @list     = $(@ele).children('[data-nested-list]')

    @list.off('click.collapse', '> li a[data-nested-add]').on('click.collapse', '> li a[data-nested-add]', (e) =>
      e.preventDefault()
      e.stopPropagation()
      @.add()
    )

    @list.on('click', '> li a[data-nested-destroy]', (e) =>
      e.preventDefault()
      e.stopPropagation()
      @.destroy($(e.currentTarget).data('nested-destroy'))
    )

  add: () =>
    timestamp = new Date().getTime()
    data = { }
    data[@key+"_index"]     = timestamp
    data[@key+"_object_id"] = timestamp
    @list.children('li:last').before( @template(data) )
    NestedInput.initialize()
    $(document).trigger('cohesive_admin.form_change') # re-initialize any new select boxes, etc.

  destroy: (id) =>
    if(confirm("Are you sure you want to delete this item?"))
      li = @list.children('[data-nested-object="'+id+'"]')
      if(li.length)
        li.find('input[id$="_destroy"]').val('1')
        li.hide()


$(document).on('cohesive_admin.initialized', () ->
  NestedInput.initialize()
)
