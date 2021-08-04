class Api::V1::Accounts::MoonboardsController < Api::V1::Accounts::BaseController
    before_action :fetch_moonboard, only: [:show, :update, :destroy, :download]
    before_action :check_authorization

    def index
      @moonboards = Current.account.moonboards
    end
  
    def show; 
    end
  
    def create
      @moonboard = Current.account.moonboards.new(moonboard_params)
      @moonboard.save!
    end
  
    def update
      @moonboard.update!(moonboard_params)
    end
  
    def destroy
      @moonboard.destroy
      head :ok
    end
  
    def download
      zipname = "#{@moonboard.title} #{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.zip".gsub('"', '\"') # escape quotes
      disposition = ActionDispatch::Http::ContentDisposition.format(disposition: "attachment", filename: zipname)
      response.headers["Content-Disposition"] = disposition
      response.headers["Content-Type"] = "application/zip"
      response.headers.delete("Content-Length")
      response.headers["Cache-Control"] = "no-cache"
      response.headers["Last-Modified"] = Time.now.httpdate.to_s
      response.headers["X-Accel-Buffering"] = "no"
  
      writer = ZipTricks::BlockWrite.new do |chunk|
        response.stream.write(chunk)
      end

      ZipTricks::Streamer.open(writer) do |zip|
        @moonboard.moonboard_items.each do |item|
          zip.write_deflated_file(item.image.filename.to_s) do |file_writer|
            item.image.blob.download do |chunk|
              file_writer << chunk
            end
          end
        end
      end
    ensure
      response.stream.close
    end

    def fetch_moonboard
      @moonboard = Current.account.moonboards.find(params[:id])
    end

    def moonboard_params
      params.require(:moonboard).permit(:title)
    end
  
    def moonboard_items
      if PAGINATE
        if params[:all]
          @moonboard_items = @moonboard.moonboard_items
        else
          @moonboard_items = @moonboard.moonboard_items.page(params[:page])
        end
      else
        @moonboard_items = @moonboard.moonboard_items
      end
  
      render json: @moonboard_items.to_json( {methods: [:image_url, :thumbnail_url]} ), status: 200
    end
  
    # def share
    #   @board = Board.find_by(share_id: params[:id])
    #   @items = @board.items.page(params[:page])
    #   render 'show'
    # end
  
    
  
    # private
    # def find_board
    #   @board = Board.find params[:id]
    # end
  
    # def board_params
    #   params.require(:board).permit(:title, :position)
    # end
  
    # def authenticate_user
    #   if Rails.env.production?
    #     authenticate_or_request_with_http_basic do |name, password|
    #       name == ENV['USERNAME'] && password == ENV['PASSWORD']
    #     end
    #   end
    # end
  end