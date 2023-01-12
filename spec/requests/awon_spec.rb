require "rails_helper"

RSpec.describe "AWON", type: :request do
  describe "page tests" do
    it "gets index" do
      get url_for(controller: :awon)
      expect(response).to have_http_status(:success)
    end

    it "gets station_info" do
      get url_for(controller: :awon, action: :station_info)
      expect(response).to have_http_status(:success)
    end
  end
end
