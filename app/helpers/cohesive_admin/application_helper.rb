module CohesiveAdmin
  module ApplicationHelper

    def inverse_relationship_exists?(child, association, parent)
      association = association.to_s
      (parent.reflections.values.include?(child.reflections[association].inverse_of) rescue false)
    end

    def admin_config_to_js
      # pass CohesiveAdmin config settings down to Javascript
      js_config = {
        managed_models: {},
        aws: nil,
        froala: { key: CohesiveAdmin.config.froala[:key] },
        mount_point: root_path
      }

      # models
      CohesiveAdmin.config.managed_models.each {|m| js_config[:managed_models][m.name] = m.admin_attributes }

      # AWS settings
      unless CohesiveAdmin.config.aws.blank?
        # Froala requires that we provide the region-specific endpoint as the 'region' parameter. We'll use the aws-sdk gem to provide this.
        bucket = Aws::S3::Bucket.new(CohesiveAdmin.config.aws[:bucket], { region: CohesiveAdmin.config.aws[:region] })
        region = bucket.client.config.endpoint.host.gsub(/\.amazonaws\.com\Z/, '')

        js_config[:aws] = {
            bucket:         CohesiveAdmin.config.aws[:bucket],
            region:         region,
            key_start:      CohesiveAdmin.config.aws[:key_start],
            acl:            CohesiveAdmin.config.aws[:acl],
            access_key_id:  CohesiveAdmin.config.aws[:access_key_id],
            policy:         CohesiveAdmin::AmazonSignature.policy,
            signature:      CohesiveAdmin::AmazonSignature.signature,
            assets:         {
                              index:      s3_assets_path,
                              delete:     delete_s3_assets_path,
                              preloader:  asset_path('cohesive_admin/preloader.gif')
                            }
        }
      end

      javascript_tag do
        raw %Q{
          $(function() {
            CohesiveAdmin.initialize(#{js_config.to_json})
          })
        }
      end
    end

    def link_to_add_nested(name, f, association)
      new_object = f.object.send(association).klass.new
      id = new_object.object_id
      fields = f.fields_for(association, new_object, child_index: id) do |builder|
        render("cohesive_admin/base/fields", klass: new_object.class, f: builder, include_destroy: true)
      end

      fields = "<div class='card-panel blue lighten-5'>" + fields + "</div>"
      link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
    end

  end
end
