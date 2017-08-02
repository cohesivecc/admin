#= require jquery2
#= require jquery-ui
#= require jquery_ujs
#= require_tree ./includes
#= require_tree ./app
#= require_tree ./inputs
#= require materialize

$(->
  $(document).trigger('turbolinks:load')
  CohesiveAdmin.initialize()
)
