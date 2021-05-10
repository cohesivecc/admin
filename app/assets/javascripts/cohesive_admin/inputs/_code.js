$(document).on('cohesive_admin.initialized', () => $('textarea.code').each(function() {
  return CodeMirror.fromTextArea($(this)[0], {
    lineNumbers: true,
    styleActiveLine: true,
    matchBrackets: true,
    theme: 'material',
    mode: 'javascript'
  });
}));
