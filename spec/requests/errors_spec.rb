require "rails_helper"

RSpec.describe "Errors", type: :request do
  describe "GET /not_found" do
    it "404画面を表示する" do
      get "/not-found-page"

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("ページが見つかりません")
    end
  end
end
