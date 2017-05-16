$(document).on('cohesive_admin.initialized', () ->
  if($('#filter-form').length)
    window.setTimeout(() ->
      $('#filter-form label.select').each(() ->
        input = $('#filter-form #'+$(@).attr('for'))
        if($.trim(input.val()) != '')
          $("#filter-container .collapsible-header .secondary-content").append('<div class="chip"><span class="grey-text text-lighten-1">'+$(@).html()+':</span> '+input.find('option:selected').text()+'</div>')
      )
      $('#filter-form label.string').each(() ->
        input = $('#filter-form #'+$(@).attr('for'))
        if($.trim(input.val()) != '')
          $("#filter-container .collapsible-header .secondary-content").append('<div class="chip"><span class="grey-text text-lighten-1">'+$(@).html()+':</span> '+$.trim(input.val())+'</div>')
      )
    , 100)
)
