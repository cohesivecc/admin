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
  $(".button-collapse").sideNav()

  $('form').on 'click', '.add_fields', (event) ->
    event.preventDefault();
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))

  $('form').on 'click', '.remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.card-panel').hide()
    event.preventDefault()

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
