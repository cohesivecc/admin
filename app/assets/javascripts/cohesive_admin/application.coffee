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

  CohesiveAdmin.initialize()
