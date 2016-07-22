# asynchronously load Froala and S3 settings for security purposes
$(document).on( 'froala.init', (e, key, s3config) ->

  $.FroalaEditor.DEFAULTS.key = CohesiveAdmin.froala.key

  config = {
    zIndex: 999,
    heightMin: 300,
    toolbarButtons: ['fullscreen', 'bold', 'italic', 'underline', 'strikeThrough', 'subscript', 'superscript', 'fontFamily', 'fontSize', '|', 'color', 'emoticons', 'inlineStyle', 'paragraphStyle', '|', 'paragraphFormat', 'align', 'formatOL', 'formatUL', 'outdent', 'indent', 'quote', 'insertHR', 'insertLink', 'insertImage', 'insertVideo', 'insertFile', 'insertTable', 'undo', 'redo', 'clearFormatting', 'selectAll', 'html']
  }
  if CohesiveAdmin.aws

    config.imageUploadToS3 = {
      bucket:   CohesiveAdmin.aws.bucket,
      region:   CohesiveAdmin.aws.region,
      keyStart: CohesiveAdmin.aws.key_start + 'images/',
      callback: (url, key) ->
        # // The URL and Key returned from Amazon.
        console.log (url);
        console.log (key);
      params: {
        acl: CohesiveAdmin.aws.acl,
        AWSAccessKeyId: CohesiveAdmin.aws.access_key_id,
        policy: CohesiveAdmin.aws.policy,
        signature: CohesiveAdmin.aws.signature,
      }
    }

    config.fileUploadToS3 = {
      bucket:   CohesiveAdmin.aws.bucket,
      region:   CohesiveAdmin.aws.region,
      keyStart: CohesiveAdmin.aws.key_start + 'files/',
      callback: (url, key) ->
        # // The URL and Key returned from Amazon.
        console.log (url);
        console.log (key);
      params: {
        acl: CohesiveAdmin.aws.acl,
        AWSAccessKeyId: CohesiveAdmin.aws.access_key_id,
        policy: CohesiveAdmin.aws.policy,
        signature: CohesiveAdmin.aws.signature,
      }
    }

    config.imageManagerLoadURL      = CohesiveAdmin.aws.assets.index
    config.imageManagerDeleteURL    = CohesiveAdmin.aws.assets.delete
    config.imageManagerDeleteMethod = 'DELETE'
    config.imageManagerDeleteParams = {
                                        authenticity_token: $('meta[name="csrf-token"]').attr('content'),
                                        type: 'image'
                                      }
    config.imageManagerPreloader    = CohesiveAdmin.aws.assets.preloader


  $('textarea.wysiwyg').froalaEditor(config)
)
