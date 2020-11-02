class AsosDatum < ApplicationRecord
  belongs_to :asos_station
  include Assessable
end
