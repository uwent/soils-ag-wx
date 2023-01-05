require 'rails_helper'

RSpec.describe "Sites", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/sites/index"
      expect(response).to have_http_status(:success)
    end
  end

end
