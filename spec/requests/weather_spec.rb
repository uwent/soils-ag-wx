require "rails_helper"

RSpec.describe "Weather", type: :request do
  describe "page tests" do
    it "gets index" do
      get url_for(controller: :weather)
      expect(response).to have_http_status(:success)
    end

    it "gets weather" do
      get url_for(controller: :weather, action: :weather)
      expect(response).to have_http_status(:success)
    end

    it "gets precip" do
      get url_for(controller: :weather, action: :precip)
      expect(response).to have_http_status(:success)
    end

    it "gets et" do
      get url_for(controller: :weather, action: :et)
      expect(response).to have_http_status(:success)
    end

    it "gets insol" do
      get url_for(controller: :weather, action: :insol)
      expect(response).to have_http_status(:success)
    end

    it "gets hyd" do
      get url_for(controller: :weather, action: :hyd)
      expect(response).to have_http_status(:success)
    end

    it "gets doycal" do
      get url_for(controller: :weather, action: :doycal)
      expect(response).to have_http_status(:success)
    end
  end
end
