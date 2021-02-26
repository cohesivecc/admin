require_dependency "cohesive_admin/application_controller"

# Controller providing simple management of image and file assets for the Froala WYSIWYG editor
module CohesiveAdmin
  class S3AssetsController < ApplicationController

    before_action :load_bucket

    def index


      @items = []
      # , encoding_type: 'url'
      @bucket.objects({ prefix: @prefix }).each do |o|
        @items << { url: o.public_url, thumb: o.public_url, key: o.key }
      end

      respond_to do |format|
        format.html {
          render json: @items
        }
      end
    end

    def delete
      # attempt to prevent manipulation
      if params["data-key"].index(@prefix) == 0
        @item = @bucket.object(params["data-key"])
        if @item.exists?
          # good to delete
          begin
            @item.delete
            respond_to do |format|
              format.html {
                render json: { status: 'success' }
              }
            end and return
          rescue => exception
            error = "Delete failed. AWS Error."
          end
        else
          error = "File not found: #{params["data-key"]}"
        end
      else
        error = "Invalid file key: #{params["data-key"]}"
      end

      respond_to do |format|
        format.html {
          render json: { error: error }
        }
      end
    end

    private
      def load_bucket
        @bucket = Aws::S3::Bucket.new(CohesiveAdmin.config.aws[:bucket])
        type = %w{images files}.include?(params[:type]) ? params[:type] : 'images'
        @prefix = %Q{#{CohesiveAdmin.config.aws[:key_start]}#{type}/}
      end

  end
end
