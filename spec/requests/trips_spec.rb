require 'rails_helper'

RSpec.describe "Trips", type: :request do
  describe "GET /trips" do
    context "ログインしている場合" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }

      before do
        login_as(user)
      end

      it "旅行一覧画面を表示する" do
        get trips_path

        expect(response).to have_http_status(:ok)
      end

      it "自分の旅行を表示する" do
        trip = create(:trip, user:, destination: "京都")

        get trips_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("京都")
      end

      it "他のユーザーの旅行を表示しない" do
        create(:trip, user: other_user, destination: "大阪")

        get trips_path

        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("大阪")
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトする" do
        get trips_path

        expect(response).to redirect_to(login_path)
      end
    end
  end
end
