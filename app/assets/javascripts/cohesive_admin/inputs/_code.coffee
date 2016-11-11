
$(document).on('turbolinks:load', () ->
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
