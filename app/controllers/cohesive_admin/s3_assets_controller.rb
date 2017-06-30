# Controller providing simple management of image and file assets for the Froala WYSIWYG editor
class CohesiveAdmin::S3AssetsController < CohesiveAdmin::BaseController

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
    if params[:key].index(@prefix) == 0
      @item = @bucket.object(params[:key])
      if @item.exists?
        # good to delete
        if (resp = @item.delete).successful?
          respond_to do |format|
            format.html {
              render json: { status: 'success' }
            }
          end and return
        else
          error = "Delete failed: #{resp.error.message}"
        end
      else
        error = "File not found: #{params[:key]}"
      end
    else
      error = "Invalid file key: #{params[:key]}"
    end

    respond_to do |format|
      format.html {
        render json: { error: error }
      }
    end
  end

private

  def load_bucket
    logger.info 'CohesiveAdmin.config.aws[:key_start]'
    logger.info CohesiveAdmin.config.aws[:key_start]
    @bucket = Aws::S3::Bucket.new(CohesiveAdmin.config.aws[:bucket])
    type = %w{images files}.include?(params[:type]) ? params[:type] : 'images'
    @prefix = %Q{#{CohesiveAdmin.config.aws[:key_start]}#{type}/}
  end

end
