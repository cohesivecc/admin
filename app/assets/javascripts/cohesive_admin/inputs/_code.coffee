
$(document).on('cohesive_admin.initialized', () ->
  $('textarea.code').each(() ->
    CodeMirror.fromTextArea($(@)[0], {
      lineNumbers: true,
      styleActiveLine: true,
      matchBrackets: true,
      theme: 'material',
      mode: 'javascript'
    })
  )
)
