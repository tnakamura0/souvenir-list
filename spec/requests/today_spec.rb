require "rails_helper"

RSpec.describe "Today", type: :request do
  describe "GET /" do
    around do |example|
      travel_to(Date.new(2026, 8, 7)) do
        example.run
      end
    end

    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      context "今日の旅行が1件ある場合" do
        let!(:today_trip) do
          create(
            :trip,
            user:,
            name: "今日の旅行",
            departure_date: Date.new(2026, 8, 6),
            return_date: Date.new(2026, 8, 8)
          )
        end

        let!(:past_trip) do
          create(
            :trip,
            user:,
            name: "過去の旅行",
            departure_date: Date.new(2026, 8, 1),
            return_date: Date.new(2026, 8, 3)
          )
        end

        let!(:future_trip) do
          create(
            :trip,
            user:,
            name: "未来の旅行",
            departure_date: Date.new(2026, 8, 10),
            return_date: Date.new(2026, 8, 12)
          )
        end

        let(:other_user) { create(:user) }

        let!(:other_trip) do
          create(
            :trip,
            user: other_user,
            name: "他のユーザーの旅行",
            departure_date: Date.new(2026, 8, 6),
            return_date: Date.new(2026, 8, 8)
          )
        end

        it "今日の旅行を表示する" do
          get root_path

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("今日の旅行")
        end

        it "過去の旅行を表示しない" do
          get root_path

          expect(response.body).not_to include("過去の旅行")
        end

        it "未来の旅行を表示しない" do
          get root_path

          expect(response.body).not_to include("未来の旅行")
        end

        it "他のユーザーの旅行を表示しない" do
          get root_path

          expect(response.body).not_to include("他のユーザーの旅行")
        end
      end

      context "今日の旅行が複数ある場合" do
        let!(:today_trip_1) do
          create(
            :trip,
            user:,
            name: "出発日が古い旅行",
            departure_date: Date.new(2026, 8, 5),
            return_date: Date.new(2026, 8, 7)
          )
        end

        let!(:today_trip_2) do
          create(
            :trip,
            user:,
            name: "出発日が新しい旅行",
            departure_date: Date.new(2026, 8, 7),
            return_date: Date.new(2026, 8, 8)
          )
        end

        it "出発日が最も古い旅行を初期表示する" do
          get root_path

          expect(response.parsed_body.at_css("h1").text).to eq("出発日が古い旅行")
        end

        it "trip_idを指定すると指定した旅行を表示する" do
          get root_path, params: { trip_id: today_trip_2.id }

          expect(response.parsed_body.at_css("h1").text).to eq("出発日が新しい旅行")
        end
      end

      context "今日の旅行が存在しない場合" do
        it "空状態を表示する" do
          get root_path

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("今日は旅行の予定がありません")
          expect(response.body).to include("旅行を新規作成する")
        end
      end

      context "不正なtrip_idが指定された場合" do
        context "今日ではない旅行を指定した場合" do
          let!(:past_trip) do
            create(
              :trip,
              user:,
              name: "過去の旅行",
              departure_date: Date.new(2026, 8, 1),
              return_date: Date.new(2026, 8, 3)
            )
          end

          it "404を返す" do
            get root_path, params: { trip_id: past_trip.id }

            expect(response).to have_http_status(:not_found)
          end
        end

        context "他のユーザーの旅行を指定した場合" do
          let(:other_user) { create(:user) }

          let!(:other_trip) do
            create(
              :trip,
              user: other_user,
              name: "他のユーザーの旅行",
              departure_date: Date.new(2026, 8, 6),
              return_date: Date.new(2026, 8, 8)
            )
          end

          it "404を返す" do
            get root_path, params: { trip_id: other_trip.id }

            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトする" do
        get root_path

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_nil
      end
    end
  end
end
