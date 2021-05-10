$(document).on('cohesive_admin.initialized', function() {
  if($('#search-form').length) {
    return window.setTimeout(() => $('#search-form label').each(function() {
      const input = $('#search-form #'+$(this).attr('for'));
      if($.trim(input.val()) !== '') {
        return $("#search-container .collapsible-header .secondary-content").append('<div class="chip"><span class="grey-text text-lighten-1">'+$(this).html()+':</span> '+input.find('option:selected').text()+'</div>');
      }
    })
    , 100);
  }
});
