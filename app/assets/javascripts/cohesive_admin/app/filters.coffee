$(document).on('cohesive_admin.initialized', () ->
  if($('#filter-form').length)
    window.setTimeout(() ->
      $('#filter-form label').each(() ->
        input = $('#filter-form #'+$(@).attr('for'))
        if($.trim(input.val()) != '')
          $("#search-container .collapsible-header .secondary-content").append('<div class="chip"><span class="grey-text text-lighten-1">'+$(@).html()+':</span> '+input.find('option:selected').text()+'</div>')
      )
    , 100)
)
