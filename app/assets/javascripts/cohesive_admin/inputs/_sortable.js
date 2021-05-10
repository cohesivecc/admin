$(document).on('turbolinks:load', function() {
  return $('[data-sortable]').sortable({
    containment: 'parent',
    cursor: 'move',
    update() {
      const list = $(this);
      return $.ajax({
        type: 'put',
        data: list.sortable('serialize'),
        dataType: 'script',
        complete(request) {
          list.children().effect('highlight');
        },
        url: list.attr('data-url')
      });
    }
    });
});
