require 'rails_helper'

RSpec.describe "Thermal Models", type: :request do
  describe "page tests" do
    it "gets index" do
      get url_for(controller: :thermal_models)
      expect(response).to have_http_status(:success)
    end

    it "gets alfalfa_weevil" do
      get url_for(controller: :thermal_models, action: :alfalfa_weevil)
      expect(response).to have_http_status(:success)
    end

    it "gets corn_dev" do
      get url_for(controller: :thermal_models, action: :corn_dev)
      expect(response).to have_http_status(:success)
    end

    it "gets corn_stalk_borer" do
      get url_for(controller: :thermal_models, action: :corn_stalk_borer)
      expect(response).to have_http_status(:success)
    end

    it "gets dd_map" do
      get url_for(controller: :thermal_models, action: :dd_map)
      expect(response).to have_http_status(:success)
    end

    it "gets degree_days" do
      get url_for(controller: :thermal_models, action: :degree_days)
      expect(response).to have_http_status(:success)
    end

    it "gets ecb" do
      get url_for(controller: :thermal_models, action: :ecb)
      expect(response).to have_http_status(:success)
    end

    it "gets oak_wilt" do
      get url_for(controller: :thermal_models, action: :oak_wilt)
      expect(response).to have_http_status(:success)
    end

    it "gets potato" do
      get url_for(controller: :thermal_models, action: :potato)
      expect(response).to have_http_status(:success)
    end

    it "gets scm" do
      get url_for(controller: :thermal_models, action: :scm)
      expect(response).to have_http_status(:success)
    end

    it "gets spongy_moth" do
      get url_for(controller: :thermal_models, action: :spongy_moth)
      expect(response).to have_http_status(:success)
    end

    it "gets western_bean_cutworm" do
      get url_for(controller: :thermal_models, action: :western_bean_cutworm)
      expect(response).to have_http_status(:success)
    end
  end
end