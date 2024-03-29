require File.join(File.dirname(__FILE__), "..", "config", "environment.rb")
require "fileutils"
require "webcam_access"

CAM_HOME = ARGV[0] || "/var/www/soils-agwx-assets/uwex_agwx/images/webcam"

def num_part(fname)
  fname =~ /(\d{3}).jpg/
  begin
    $1.to_i
  rescue
    0
  end
end

def next_link_name(folder, root = "half")
  pattern = "#{root}_sequence_*.jpg"
  existing = Dir.glob("#{folder}/#{pattern}").sort { |a, b| num_part(a) <=> num_part(b) }
  next_index = if existing.size > 0
    num_part(existing.last) + 1
  else
    1
  end
  "#{root}_sequence_#{sprintf("%03d", next_index)}.jpg"
end

# Note: Timestamp should be IN LOCAL TIME. DateTime.now correctly sets the timezone, so that works.
def archive(timestamp, cam_home = CAM_HOME)
  folder = File.join(cam_home, "archive", timestamp.strftime("%Y"), timestamp.strftime("%m"), timestamp.strftime("%d"))
  FileUtils.mkdir_p(folder)
  fname = WebcamImage.half_filename(timestamp)
  dest = File.join(folder, fname)
  FileUtils.cp(File.join(cam_home, "halfsize.jpg"), dest)
  link_name = next_link_name(folder, "half")
  FileUtils.symlink(dest, File.join(folder, link_name))
  WebcamImage.create! timestamp:, fname:, sequence_fname: link_name, size: WEBCAM_THUMB
  fname = WebcamImage.full_filename(timestamp)
  dest = File.join(folder, fname)
  FileUtils.cp(File.join(cam_home, "fullsize.jpg"), dest)
  link_name = next_link_name(folder, "full")
  FileUtils.symlink(dest, File.join(folder, link_name))
  WebcamImage.create! timestamp:, fname:, sequence_fname: link_name, size: WEBCAM_FULL
end

Net::HTTP.start(CAM_ADDR) do |http|
  puts "Failed!" unless geddit(http, "/axis-cgi/jpg/image.cgi?resolution=320x240", CAM_HOME, "halfsize.jpg")
  puts "Failed!" unless geddit(http, "/jpg/image.jpg", CAM_HOME, "fullsize.jpg")
  archive(DateTime.now)
end
