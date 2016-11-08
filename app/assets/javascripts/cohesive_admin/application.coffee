#= require jquery2
#= require jquery-ui
#= require jquery_ujs
#= require materialize-sprockets
#= require_tree ./includes
#= require_tree ./app
#= require_tree ./inputs

$ ->
  # kick things off
  $('select').material_select()
  $('.modal').modal()
  $('.collapsible').collapsible()
  $(".button-collapse").sideNav()

  $('[data-nested]').on 'click', '[data-add]', (event) ->
    event.preventDefault();
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))

  $('[data-nested]').on 'click', '[data-destroy]', (event) ->
    event.preventDefault()
    event.stopPropagation()
    if(confirm("Are you sure you want to delete this item?"))
      obj = $('[data-object="'+$(@).data('destroy')+'"]')
      obj.find('input[id$="_destroy"]').val('1')
      obj.hide()

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
