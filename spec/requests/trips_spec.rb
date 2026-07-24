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

  describe "GET /trips/new" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      it "旅行作成画面を表示する" do
        get new_trip_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトする" do
        get new_trip_path

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "POST /trips" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      it "正常な値なら旅行を作成できる" do
        expect {
          post trips_path, params: {
            trip: {
              name: "東京出張",
              destination: "東京",
              departure_date: Date.today,
              return_date: Date.today
            }
          }
        }.to change(user.trips, :count).by(1)

        expect(response).to redirect_to(trips_path)
        expect(flash[:notice]).to eq("旅行を作成しました")
      end

      it "不正な値なら旅行が作成できない" do
        expect {
          post trips_path, params: {
            trip: {
              name: "東京出張",
              destination: "",
              departure_date: Date.today,
              return_date: Date.today
            }
          }
        }.not_to change(user.trips, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to eq("旅行を作成できませんでした")
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトする" do
        post trips_path, params: {
          trip: {
            name: "東京出張",
            destination: "東京",
            departure_date: Date.today,
            return_date: Date.today
          }
        }

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("ログインしてください")
      end
    end
  end
end
