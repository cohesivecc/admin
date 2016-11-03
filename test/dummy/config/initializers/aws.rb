# AWS_CONFIG = {
#   # 'access_key_id' => '',
#   # 'secret_access_key' => '',
#   credentials: Aws::SharedCredentials.new(profile_name: 'cohesive_admin'),
#   region: 'us-west-2',
#   bucket: 'cohesive-admin-dev',
#   acl: 'public-read'
# }
# Aws.config.update({
#   region:       AWS_CONFIG[:region],
#   credentials:  AWS_CONFIG[:credentials]
# })

Aws.config.update({
  region:       'us-west-2',
  credentials:  Aws::SharedCredentials.new(profile_name: 'cohesive_admin')
})
