

class window.NestedInput

  @initialize: () ->
    if(typeof(Handlebars) != 'undefined') # Handlebars is required
      $('[data-nested]').each( () ->
        if($(@).data('nested') == '')
          $(@).data('nested', new NestedInput($(@)))
      )

  constructor: (@ele) ->

    @template = Handlebars.compile($(@ele).children('[data-nested-template]').remove().html())
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
    @list.children('li:last').before( @template({ index: timestamp, object_id: timestamp }) )
    NestedInput.initialize()
    $(document).trigger('cohesive_admin.form_change') # re-initialize any new select boxes, etc.

  destroy: (id) =>
    if(confirm("Are you sure you want to delete this item?"))
      li = @list.children('[data-nested-object="'+id+'"]')
      if(li.length)
        li.find('input[id$="_destroy"]').val('1')
        li.hide()


$(document).on('turbolinks:load', () ->
  NestedInput.initialize()
)
