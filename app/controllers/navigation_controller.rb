class NavigationController < ApplicationController
  def index
  end

  def about
    @app_last_updated = if File.exist?(File.join(Rails.root, "REVISION"))
      File.mtime(File.join(Rails.root, "REVISION")).to_date
    else
      "Unknown"
    end
  end

  def king_hall
  end
end
