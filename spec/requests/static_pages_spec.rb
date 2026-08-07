require "rails_helper"

RSpec.describe "StaticPages", type: :request do
  describe "GET /" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      it "今日の旅行画面へリダイレクトする" do
        get root_path

        expect(response).to redirect_to(today_path)
      end
    end

    context "ログインしていない場合" do
      it "トップページを表示する" do
        get root_path

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
