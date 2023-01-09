require 'rails_helper'

RSpec.describe "Navigation", type: :request do
  describe "page tests" do
    it "gets index" do
      get url_for(controller: :navigation)
      expect(response).to have_http_status(:success)
    end

    it "gets about" do
      get url_for(controller: :navigation, action: :about)
      expect(response).to have_http_status(:success)
    end

    it "gets king_hall" do
      get url_for(controller: :navigation, action: :king_hall)
      expect(response).to have_http_status(:success)
    end
  end
end
