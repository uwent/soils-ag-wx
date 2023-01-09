require 'rails_helper'

RSpec.describe "Weather", type: :request do
  describe "GET #index" do
    it "returns http success" do
      get "/weather"
      expect(response).to have_http_status(:success)
    end
  end

end
