#= require jquery2
#= require materialize
#= require jquery-ui
#= require jquery_ujs
#= require_tree ./includes
#= require_tree ./app
#= require_tree ./inputs

$(->
  $(document).trigger('turbolinks:load')
  CohesiveAdmin.initialize()
)
