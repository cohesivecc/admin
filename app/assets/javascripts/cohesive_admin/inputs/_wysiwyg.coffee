# asynchronously load Froala and S3 settings for security purposes
$(document).on( 'cohesive_admin.initialized', (e) ->

  config = CohesiveAdmin.config

  FroalaEditor.DEFAULTS.key = config.froala.key

  froala_config = {
    zIndex: 999,
    heightMin: 300,
    toolbarButtons: {
      'moreText': {
        'buttons': ['bold', 'italic', 'underline', 'strikeThrough', 'subscript', 'superscript', 'fontFamily', 'fontSize', 'textColor', 'backgroundColor', 'inlineClass', 'inlineStyle', 'clearFormatting']
      },
      'moreParagraph': {
        'buttons': ['alignLeft', 'alignCenter', 'formatOLSimple', 'alignRight', 'alignJustify', 'formatOL', 'formatUL', 'paragraphFormat', 'paragraphStyle', 'lineHeight', 'outdent', 'indent', 'specialCharacters', 'quote']
      },
      'moreRich': {
        'buttons': ['insertLink', 'insertImage', 'insertVideo', 'insertTable', 'emoticons', 'fontAwesome', 'specialCharacters', 'embedly', 'insertFile', 'insertHR']
      },
      'moreMisc': {
        'buttons': ['undo', 'redo', 'fullscreen', 'spellChecker', 'selectAll', 'html', 'help'],
        'align': 'right',
        'buttonsVisible': 2
      }
    }
  }
  FroalaEditor.DEFAULTS.specialCharactersSets.push({
    title: 'Other',
    char: '&Amacr;',
    list: [
      { 'char': '&Amacr;', desc: 'LATIN CAPITAL A WITH MACRON' },
      { 'char': '&amacr;', desc: 'LATIN LOWERCASE A WITH MACRON' },
      { 'char': '&Umacr;', desc: 'LATIN CAPITAL U WITH MACRON' },
      { 'char': '&#363;', desc: 'LATIN LOWERCASE U WITH MACRON' },
    ]
  })

  if config.aws

    froala_config.imageUploadToS3 = {
      bucket:   config.aws.bucket,
      region:   config.aws.region,
      keyStart: config.aws.key_start + 'images/',
      callback: (url, key) ->
        # // The URL and Key returned from Amazon.
        # console.log (url);
        # console.log (key);
      params: {
        acl: config.aws.acl,
        AWSAccessKeyId: config.aws.access_key_id,
        policy: config.aws.policy,
        signature: config.aws.signature,
      }
    }

    froala_config.fileUploadToS3 = {
      bucket:   config.aws.bucket,
      region:   config.aws.region,
      keyStart: config.aws.key_start + 'files/',
      callback: (url, key) ->
        # // The URL and Key returned from Amazon.
        # console.log (url);
        # console.log (key);
      params: {
        acl: config.aws.acl,
        AWSAccessKeyId: config.aws.access_key_id,
        policy: config.aws.policy,
        signature: config.aws.signature,
      }
    }

    froala_config.imageManagerLoadURL      = config.aws.assets.index
    froala_config.imageManagerDeleteURL    = config.aws.assets.delete
    froala_config.imageManagerDeleteMethod = 'DELETE'
    froala_config.imageManagerDeleteParams = {
                                                authenticity_token: $('meta[name="csrf-token"]').attr('content'),
                                                type: 'image'
                                              }
    froala_config.imageManagerPreloader    = config.aws.assets.preloader

  CohesiveAdmin.config.froala.config = froala_config
  $.extend(FroalaEditor.DEFAULTS, froala_config)
  new FroalaEditor('textarea.wysiwyg')
)
