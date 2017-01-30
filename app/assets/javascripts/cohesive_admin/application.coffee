#= require jquery2
#= require jquery-ui
#= require jquery_ujs
#= require turbolinks
#= require materialize-sprockets
#= require_tree ./includes
#= require_tree ./app
#= require_tree ./inputs




$(document).on('turbolinks:load', () ->

  # kick things off
  CohesiveAdmin.initialize();

)
