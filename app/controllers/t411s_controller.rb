class T411sController < ApplicationController

  # Get datestamp (in Campbell Sci format) of last-uploaded 411.
  def last
    p = params.permit(:stnid,:format)
    stnid_str = p[:stnid] || '4751'
    desired = p(:format)
    stn_id = AwonStation.find_by_stnid(stnid_str)[:id]
    date = T411.where(awon_station_id: stn_id).order('date').last.date
    @date_str = date.strftime("%y%j")
    respond_to  do |format|
      format.html { render  text: @date_str }
      format.json { render json:  @date_str }
    end
  end

end
