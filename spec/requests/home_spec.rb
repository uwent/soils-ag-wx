require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "page tests" do
    it "gets index" do
      get url_for(controller: :home)
      expect(response).to have_http_status(:success)
    end

    it "gets about" do
      get url_for(controller: :home, action: :about)
      expect(response).to have_http_status(:success)
    end

    it "gets king_hall" do
      get url_for(controller: :home, action: :king_hall)
      expect(response).to have_http_status(:success)
    end
  end
end
