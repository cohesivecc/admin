$(document).on( 'cohesive_admin.initialized', (e) ->

  $('[data-nested-title]').on 'click', '[data-add]', (event) ->
    event.preventDefault();
    object_id = new Date().getTime()
    source = $('[data-nested-template]').html();
    template = Handlebars.compile(source);
    data_name = $(@).data('add')
    index_value = $('[data-nested] .collapsible-body').last().find("label").attr('for')
    if index_value != undefined
      index = parseInt(index_value.match(/\d+/)[0] ) + 1
    else
      index = 0

    context = { index: index, object_id: object_id }
    html = template(context)
    $('[data-nested="'+data_name+'"]').append(html)

  $('[data-nested]').on 'click', '[data-destroy]', (event) ->
    event.preventDefault()
    event.stopPropagation()
    if(confirm("Are you sure you want to delete this item?"))
      obj = $('[data-object="'+$(@).data('destroy')+'"]')
      obj.find('input[id$="_destroy"]').val('1')
      obj.hide()

)
