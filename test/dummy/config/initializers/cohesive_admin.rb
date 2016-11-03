CohesiveAdmin.configure do |config|
  config.aws = {
    credentials: Aws.config[:credentials],
    region: Aws.config[:region],
    bucket: 'cohesive-admin-dev',
    acl: 'public-read'
  }
  # config.froala = { key: 'KEY HERE' }
end
