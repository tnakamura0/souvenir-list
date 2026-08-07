require "rails_helper"

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
        create(:trip, user:, destination: "京都")

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
            trip: attributes_for(:trip)
          }
        }.to change(user.trips, :count).by(1)

        expect(response).to redirect_to(trips_path)
        expect(flash[:notice]).to eq("旅行を作成しました")
      end

      it "不正な値なら旅行が作成できない" do
        expect {
          post trips_path, params: {
            trip: attributes_for(:trip, destination: "")
          }
        }.not_to change(user.trips, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to eq("旅行を作成できませんでした")
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトする" do
        post trips_path, params: {
          trip: attributes_for(:trip)
        }

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("ログインしてください")
      end
    end
  end

  describe "GET /trips/:id" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      context "自分の旅行を指定した場合" do
        let(:trip) { create(:trip, user:) }

        it "旅行詳細画面を表示する" do
          get trip_path(trip)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include(trip.destination)
        end

        it "旅行に追加済みの相手と人数を表示する" do
          recipient = create(
            :recipient,
            user:,
            name: "職場",
            kind: "group",
            people_count: 5
          )
          create(:trip_recipient, trip:, recipient:)

          get trip_path(trip)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("職場")
          expect(response.body).to include("5人")
        end

        it "他の旅行に追加されている相手を表示しない" do
          other_trip = create(:trip, user:)
          recipient = create(:recipient, user:, name: "別の旅行に追加した相手")
          create(:trip_recipient, trip: other_trip, recipient:)

          get trip_path(trip)

          expect(response).to have_http_status(:ok)
          expect(response.body).not_to include("別の旅行に追加した相手")
        end

        it "相手が追加されていない場合は空状態を表示する" do
          get trip_path(trip)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("お土産を渡す相手がまだ追加されていません")
          expect(response.body).to include("相手を追加する")
        end

        it "追加済みの相手のタグを表示する" do
          recipient = create(:recipient, user:)
          tag = create(:tag, user:, name: "友人")

          create(:recipient_tag, recipient:, tag:)
          create(:trip_recipient, trip:, recipient:)

          get trip_path(trip)

          expect(response.body).to include("友人")
        end
      end

      context "他のユーザーの旅行を指定した場合" do
        let(:other_user) { create(:user) }
        let(:trip) { create(:trip, user: other_user) }

        it "旅行詳細画面を表示しない" do
          get trip_path(trip)

          expect(response).to have_http_status(:not_found)
        end
      end

      context "存在しない旅行を指定した場合" do
        it "旅行詳細画面を表示しない" do
          get trip_path(id: 0)

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "ログインしていない場合" do
      let(:trip) { create(:trip) }

      it "ログイン画面へリダイレクトする" do
        get trip_path(trip)

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("ログインしてください")
      end
    end
  end

  describe "GET /trips/:id/edit" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      context "自分の旅行を指定した場合" do
        let(:trip) { create(:trip, user:) }

        it "旅行編集画面を表示する" do
          get edit_trip_path(trip)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include(trip.name)
        end
      end

      context "他ユーザーの旅行を指定した場合" do
        let(:other_user) { create(:user) }
        let(:trip) { create(:trip, user: other_user) }

        it "旅行編集画面を表示しない" do
          get edit_trip_path(trip)

          expect(response).to have_http_status(:not_found)
        end
      end

      context "存在しない旅行を指定した場合" do
        it "旅行編集画面を表示しない" do
          get edit_trip_path(id: 0)

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "ログインしていない場合" do
      let(:trip) { create(:trip) }

      it "ログイン画面へリダイレクトする" do
        get edit_trip_path(trip)

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("ログインしてください")
      end
    end
  end

  describe "PATCH /trips/:id" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      context "自分の旅行を指定した場合" do
        let(:trip) { create(:trip, user:, name: "更新前の旅行名") }

        it "正常な値なら旅行を更新できる" do
          patch trip_path(trip), params: {
            trip: attributes_for(:trip, name: "更新後の旅行名")
          }

          expect(response).to redirect_to(trip_path(trip))
          expect(flash[:notice]).to eq("旅行を更新しました")
          expect(trip.reload.name).to eq("更新後の旅行名")
        end

        it "不正な値なら旅行を更新できない" do
          patch trip_path(trip), params: {
            trip: attributes_for(:trip, name: "")
          }

          expect(response).to have_http_status(:unprocessable_content)
          expect(flash[:alert]).to eq("旅行を更新できませんでした")
          expect(trip.reload.name).to eq("更新前の旅行名")
        end
      end

      context "他のユーザーの旅行を指定した場合" do
        let(:other_user) { create(:user) }
        let(:trip) { create(:trip, user: other_user) }

        it "旅行を更新できない" do
          expect {
            patch trip_path(trip), params: {
              trip: {
                name: "更新後の旅行名"
              }
            }
          }.not_to change { trip.reload.name }

          expect(response).to have_http_status(:not_found)
        end
      end

      context "存在しない旅行を指定した場合" do
        it "旅行を更新できない" do
          patch trip_path(id: 0), params: {
            trip: {
              name: "更新後の旅行名"
            }
          }

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "ログインしていない場合" do
      let(:trip) { create(:trip) }

      it "ログイン画面へリダイレクトする" do
        patch trip_path(trip), params: {
          trip: {
            name: "更新後の旅行名"
          }
        }

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("ログインしてください")
      end
    end
  end

  describe "DELETE /trips/:id" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      context "自分の旅行を指定した場合" do
        let!(:trip) { create(:trip, user:) }

        it "旅行を削除できる" do
          expect {
            delete trip_path(trip)
          }.to change {
            Trip.exists?(trip.id)
          }.from(true).to(false)

          expect(response).to redirect_to(trips_path)
          expect(flash[:notice]).to eq("旅行を削除しました")
        end
      end

      context "他のユーザーの旅行を指定した場合" do
        let(:other_user) { create(:user) }
        let!(:trip) { create(:trip, user: other_user) }

        it "旅行を削除できない" do
          expect {
            delete trip_path(trip)
          }.not_to change(Trip, :count)

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "ログインしていない場合" do
      let!(:trip) { create(:trip) }
      it "旅行を削除せずにログイン画面へリダイレクトする" do
        expect {
          delete trip_path(trip)
        }.not_to change(Trip, :count)

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("ログインしてください")
      end
    end
  end
end
