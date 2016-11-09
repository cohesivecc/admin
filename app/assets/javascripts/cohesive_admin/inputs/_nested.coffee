$(document).on( 'cohesive_admin.initialized', (e) ->

  $('[data-nested-title]').on 'click', '[data-add]', (event) ->
    event.preventDefault();
    object_id = new Date().getTime()
    source = $('[data-nested-template]').html();
    template = Handlebars.compile(source);
    index = parseInt($('[data-nested] .collapsible-body').last().find("input[type=hidden]").attr('id').match(/\d+/)[0]) + 1
    context = { index: index, object_id: object_id }
    html = template(context)
    $('[data-nested]').append(html)

  $('[data-nested]').on 'click', '[data-destroy]', (event) ->
    event.preventDefault()
    event.stopPropagation()
    if(confirm("Are you sure you want to delete this item?"))
      obj = $('[data-object="'+$(@).data('destroy')+'"]')
      obj.find('input[id$="_destroy"]').val('1')
      obj.hide()

)
