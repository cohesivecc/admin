
// TODO: fix this listener to prevent it from firing multiple times (due to Turbolinks)

$(document).on('cohesive_admin.initialized', function(e) {
  $(document).off('change', 'select[data-polymorphic-type]').on('change', 'select[data-polymorphic-type]', function() {
    let model;
    const field         = $(this).data('polymorphic-type');
    const initial_type  = $(this).data('initial');
    const id_input      = $('select[data-polymorphic-key="'+field+'"]');
    // clear id_input
    id_input.html("<option value></option>").formSelect();

    if (id_input.length && (model = CohesiveAdmin.config.managed_models[$(this).val()])) {
      const initial_id = model.class_name === initial_type ? id_input.data('initial') : null;
      return $.ajax({
        type: 'get',
        url: model.uri,
        dataType: 'json',
        data: { page: 'all' },
        success(data) {
          const opts = ["<option value></option>"];
          $.each(data, function(i, x) {
            const selected = x.id === initial_id ? ' selected' : '';
            return opts.push('<option value="'+x.id+'" '+selected+'>'+x.to_label+'</option>');
          });
          id_input.html(opts.join('')).formSelect();
        },
        complete(request) {
        }
      });
    }
  });
  return $('select[data-polymorphic-type]').each(function() {
    if (!$(this).data('initialized')) {
      $(this).trigger('change');
      return $(this).data('initialized', true);
    }
  });

});
