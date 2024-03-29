require "net/http"
RRAF_IMAGE_URL = "/geoserver/wms?LAYERS=mmas%3Arf_map_0&STYLES=&SRS=EPSG%3A900913&FORMAT=image%2Fpng&TILED=false&TRANSPARENT=TRUE&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&_OLSALT=0.4195735566318035&BBOX=-10224913.932187,5547486.0678125,-9911827.864375,5860572.135625&WIDTH=256&HEIGHT=256"
MADISON_POPUP_URL = "/geoserver/wms?REQUEST=GetFeatureInfo&EXCEPTIONS=application%2Fvnd.ogc.se_xml&BBOX=-10480441.927412%2C5205663.525481%2C-9608448.308856%2C5988378.695012&X=435&Y=537&INFO_FORMAT=text%2Fplain&QUERY_LAYERS=mmas%3Arf_map_0&FEATURE_COUNT=50&Layers=mmas%3Arf_map_0&Styles=&Srs=EPSG%3A900913&WIDTH=713&HEIGHT=640&format=image%2Fpng"

class HeartbeatController < ApplicationController
  def index
    @sections = ["awon", "asos", "webapps", "et", "asos_grids"]
    @rraf_image_url = RRAF_IMAGE_URL
    @madison_popup_url = MADISON_POPUP_URL
  end

  def awon
    @awon_res = {}
    [4751, 4781].each do |stnid|
      awon_station = AwonStation.where(stnid:).first
      [T411, T412, T406].each do |awon_class|
        @awon_res["#{awon_station.abbrev}_#{awon_class}"] = awon_class.hasYesterday(["awon_station_id=?", awon_station[:id]])
      end
    end
    render partial: "awon"
  end

  def asos
    stn_id = AsosStation.where(stnid: "KAIG").first[:id]
    @asos_res = {"KAIG" => AsosDatum.hasYesterday(["asos_station_id = ?", stn_id])}
    render partial: "asos"
  end

  def hyd
    render partial: "hyd"
  end

  def dd
    render partial: "dd"
  end

  def et
    # Have to specify the date for this, otherwise it defaults to a Time -- may need to fix that
    @et_res = {"44.0,-92.0" => WiMnDet.hasYesterday(["latitude = ? and w920 is not null", 44.0], Date.today - 1)}
    render partial: "et"
  end

  def asos_grids
    @asos_grid_res =
      [WiMnDAveTAir, WiMnDMinTAir, WiMnDMaxTAir, WiMnDAveVapr].inject({}) do |hash, grid_class|
        hash.merge({grid_class.to_s => grid_class.hasYesterday(["latitude = ? and w920 is not null", 44.0], Date.today - 1)})
      end
    render partial: "asos_grids"
  end

  def insol
    render partial: "insol"
  end

  def ping
    render partial: "ping"
  end

  def webapps
    # require 'net/http'
    @apps = {
      # 'wisp'      => { server: 'wisp.cals.wisc.edu',  url: '/'},
      "RRAF page" => {server: "www.manureadvisorysystem.wi.gov", url: "/app/events/runoff_forecast"},
      "RRAF Map Tile" => {server: "www.manureadvisorysystem.wi.gov", url: RRAF_IMAGE_URL},
      "RRAF Popup" => {server: "www.manureadvisorysystem.wi.gov", url: MADISON_POPUP_URL}
    }
    logger.debug "\n\n\n***************"
    @apps.each do |key, params|
      url = URI.parse("http://#{params[:server]}#{params[:url]}")
      req = Net::HTTP::Get.new(url.to_s)
      begin
        res = Net::HTTP.start(url.host, url.port) { |http|
          http.request(req)
        }
        # puts "Got response back from #{url.to_s}: #{res.body}"
        if res.code == "200"
          params[:status] = "OK"
          params[:result] = if res["content-type"] == "image/png"
            Base64.encode64(res.body)
          else
            res.body
          end
        else
          params[:status] = res.code
        end
      rescue => e
        params[:status] = "Exception"
        params[:result] = e.to_s
      end
    end
    render partial: "webapps"
  end
end
