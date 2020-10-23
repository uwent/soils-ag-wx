class AsosStationsController < ApplicationController
  before_action :set_asos_station, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate, only: [:create, :update, :delete]


  def index
    @asos_stations = AsosStation.all
  end

  def new
    @asos_station = AsosStation.new
  end

  def create
    @asos_station = AsosStation.new(asos_station_params)

    respond_to do |format|
      if @asos_station.save
        format.html { redirect_to @asos_station, notice: 'Asos station was successfully created.' }
        format.json { render action: 'show', status: :created, location: @asos_station }
      else
        format.html { render action: 'new' }
        format.json { render json: @asos_station.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @asos_station.update(asos_station_params)
        format.html { redirect_to @asos_station, notice: 'Asos station was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @asos_station.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @asos_station.destroy
    respond_to do |format|
      format.html { redirect_to asos_stations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asos_station
      @asos_station = AsosStation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def asos_station_params
      params.require(:asos_station).permit(:stnid, :state, :name, :stn_type, :latitude, :longitude)
    end
end
