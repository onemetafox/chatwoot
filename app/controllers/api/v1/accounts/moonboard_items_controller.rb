class Api::V1::Accounts::MoonboardItemsController < Api::V1::Accounts::BaseController
    require 'open-uri'
    before_action :fetch_moonboard
    before_action :check_authorization
  
    def create
      puts 'params'
      if params[:image_url]
        image = open(params[:image_url])
        uri = URI.parse(params[:image_url])
        filename = File.basename(uri.path)
      else params[:image]
        image = params[:image]
        filename = image.original_filename
      end
  
      moonboard_item = MoonboardItem.new(
        moonboard_id: params[:moonboard_id],
        position: params[:position],
        text: params[:text]
      )
  
      moonboard_item.image.attach(io: image, filename: filename)
  
      last_position = Moonboard.find(params[:moonboard_id]).moonboard_items.maximum('position') || 0
      moonboard_item.position = last_position + 1
      moonboard_item.save!
  
      render json: moonboard_item.to_json({methods: [:image_url, :thumbnail_url]}), status: 200
    end
  
    def update
      @moonboard_items.update permit_params
    end
  
    def destroy
      @moonboard_items.destroy
    end
  
    private
    def fetch_moonboard
      @moonboard = Current.account.moonboards.find(params[:moonboard_id])
    end
  
    def permit_params
      params.permit(:moonboard_id, :image, :position, :text, :id, :moonboard_items)
    end
  end
  