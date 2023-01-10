require 'rails_helper'

RSpec.describe "Sites", type: :request do
  describe "page tests" do
    it "gets index" do
      get url_for(controller: :sites)
      expect(response).to have_http_status(:success)
    end

    it "gets a site" do
      get "/sites/1.5,2.5"
      expect(response).to have_http_status(:success)
    end

    it "gets a site by params" do
      get url_for(controller: :sites, action: :show, lat: 45.0, long: -89.5)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("45.0&deg;N, -89.5&deg;W".html_safe)
    end
  end
end
