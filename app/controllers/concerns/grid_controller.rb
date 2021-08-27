require 'csv'

module GridController
  include AgwxGrids

  GRID_CLASSES = {
    'Min Temp' => WiMnDMinTAir,
    'Max Temp' => WiMnDMaxTAir,
    'Avg Temp' => WiMnDAveTAir,
    'Vapor Pressure' => WiMnDAveVapr,
    'ET' => WiMnDet,
    'Insol' => Insol
  }

  def to_csv(data)
    CSV.generate do |csv|
      csv << data.first.keys
      data.each do |h|
        csv << h.values
      end
    end
  end

end
