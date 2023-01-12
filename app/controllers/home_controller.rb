class HomeController < ApplicationController
  def index
  end

  def about
    @app_last_updated = last_updated
    @quick_links = quick_links
  end

  def king_hall
  end

  private

  def last_updated
    if File.exist?(File.join(Rails.root, "REVISION"))
      File.mtime(File.join(Rails.root, "REVISION")).to_date
    else
      "Unknown"
    end
  end

  def quick_links
    {
      "UW CALS" => "https://cals.wisc.edu",
      "UW Entomology" => "https://entomology.wisc.edu",
      "UW Vegetable Entomology" => "https://vegento.russell.wisc.edu",
      "UW Plant Pathology" => "https://plantpath.wisc.edu",
      "UW Vegetable Pathology" => "https://vegpath.plantpath.wisc.edu",
      "UW Soil Science" => "https://soils.wisc.edu",
      "UW Horticulture" => "https://hort.wisc.edu",
      "UW Agronomy" => "https://agronomy.wisc.edu"
    }.freeze
  end
end
