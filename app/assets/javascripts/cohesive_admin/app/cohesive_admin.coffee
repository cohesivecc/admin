
class window.CohesiveAdmin
  @config = null

  @initialize: (@config) ->
    # publish initialize event
    $(document).trigger('cohesive_admin.initialized')

    CohesiveAdmin.refreshForm()
    # listen for dynamic changes to the form
    $(document).off('cohesive_admin.form_change').on('cohesive_admin.form_change', () ->
      CohesiveAdmin.refreshForm()
    )

  @refreshForm: () ->
    if($('#object-form, #search-form').length)
      $('select').material_select()
      $('.collapsible').collapsible()
      Materialize.updateTextFields()
      $('textarea.wysiwyg').froalaEditor()
