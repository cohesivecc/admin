$(->
  $('[data-sortable]').sortable({
    containment: 'parent',
    cursor: 'move',
    update: () ->
      list = $(@)
      $.ajax({
        type: 'put',
        data: list.sortable('serialize'),
        dataType: 'script',
        complete: (request) ->
          list.children().effect('highlight')
          return
        url: list.attr('data-url')
      })
    })
)
