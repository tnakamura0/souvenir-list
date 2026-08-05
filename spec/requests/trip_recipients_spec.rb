require "rails_helper"

RSpec.describe "TripRecipients", type: :request do
  describe "GET /trips/:trip_id/trip_recipients/new" do
    context "ログインしている場合" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }

      before do
        login_as(user)
      end

      context "自分の旅行の場合" do
        let(:trip) { create(:trip, user:) }

        it "相手追加画面を表示する" do
          get new_trip_trip_recipient_path(trip)

          expect(response).to have_http_status(:ok)
        end

        it "自分が作成した未追加の相手を表示する" do
          recipient = create(:recipient, user:, name: "友人")

          get new_trip_trip_recipient_path(trip)

          expect(response.body).to include("友人")
        end

        it "既に旅行に追加済みの相手を表示しない" do
          recipient = create(:recipient, user:, name: "追加済みの友人")
          create(:trip_recipient, trip:, recipient:)

          get new_trip_trip_recipient_path(trip)

          expect(response.body).not_to include("追加済みの友人")
        end

        it "他のユーザーが作成した相手を表示しない" do
          other_recipient = create(:recipient, user: other_user, name: "他のユーザーの友人")

          get new_trip_trip_recipient_path(trip)

          expect(response.body).not_to include("他のユーザーの友人")
        end

        it "選択したタグが関連付いている未追加の相手だけを表示する" do
          tag = create(:tag, user:, name: "家族")

          matching_recipient = create(:recipient, user:, name: "母親")
          non_matching_recipient = create(:recipient, user:, name: "職場の同僚")
          added_recipient = create(:recipient, user:, name: "父親")

          matching_recipient.tags << tag
          added_recipient.tags << tag

          create(:trip_recipient, trip:, recipient: added_recipient)

          get new_trip_trip_recipient_path(trip), params: { tag_id: tag.id }

          expect(response.body).to include(matching_recipient.name)
          expect(response.body).not_to include(non_matching_recipient.name)
          expect(response.body).not_to include(added_recipient.name)
        end
      end

      context "他のユーザーの旅行を指定した場合" do
        let(:other_trip) { create(:trip, user: other_user) }

        it "相手追加画面へアクセスできない" do
          get new_trip_trip_recipient_path(other_trip)

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "ログインしていない場合" do
      let(:trip) { create(:trip) }

      it "ログイン画面へリダイレクトする" do
        get new_trip_trip_recipient_path(trip)

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "POST /trips/:trip_id/trip_recipients" do
    context "ログインしている場合" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      let(:trip) { create(:trip, user:) }

      before do
        login_as(user)
      end

      context "有効なパラメーターの場合" do
        it "選択した相手を旅行へ追加する" do
          recipient = create(:recipient, user:)

          expect {
            post trip_trip_recipients_path(trip), params: {
              recipient_ids: [ recipient.id ]
            }
          }.to change(TripRecipient, :count).by(1)

          expect(trip.reload.recipients).to include(recipient)
          expect(response).to redirect_to(trip_path(trip))
          expect(flash[:notice]).to eq("相手を旅行へ追加しました")
        end

        it "複数の相手を旅行へ追加する" do
          recipients = create_list(:recipient, 2, user:)

          expect {
            post trip_trip_recipients_path(trip), params: {
              recipient_ids: recipients.map(&:id)
            }
          }.to change(TripRecipient, :count).by(2)

          expect(trip.reload.recipients).to match_array(recipients)
        end
      end

      context "相手を選択していない場合" do
        it "旅行へ相手を追加せずに相手追加画面へ戻る" do
          expect {
            post trip_trip_recipients_path(trip)
          }.not_to change(TripRecipient, :count)

          expect(response).to redirect_to(new_trip_trip_recipient_path(trip))
          expect(flash[:alert]).to eq("相手を選択してください")
        end
      end

      context "他のユーザーの相手を指定した場合" do
        it "旅行へ相手を追加せず相手追加画面へ戻る" do
          other_recipient = create(:recipient, user: other_user)

          expect {
            post trip_trip_recipients_path(trip), params: {
              recipient_ids: [ other_recipient.id ]
            }
          }.not_to change(TripRecipient, :count)

          expect(response).to redirect_to(new_trip_trip_recipient_path(trip))
          expect(flash[:alert]).to eq("追加できない相手が含まれています")
        end
      end

      context "他のユーザーの旅行を指定した場合" do
        let(:recipient) { create(:recipient, user:) }
        let(:trip) { create(:trip, user: other_user) }

        it "旅行へ相手を追加できない" do
          expect {
            post trip_trip_recipients_path(trip), params: {
              recipient_ids: [ recipient.id ]
            }
          }.not_to change(TripRecipient, :count)

          expect(response).to have_http_status(:not_found)
        end
      end

      context "既に追加済みの相手を指定した場合" do
        it "中間レコードが重複して作成されない" do
          recipient = create(:recipient, user:)
          create(:trip_recipient, trip:, recipient:)

          expect {
            post trip_trip_recipients_path(trip), params: {
              recipient_ids: [ recipient.id ]
            }
          }.not_to change(TripRecipient, :count)
        end
      end
    end

    context "ログインしていない場合" do
      let(:trip) { create(:trip) }

      it "ログイン画面へリダイレクトする" do
        recipient = create(:recipient)

        post trip_trip_recipients_path(trip), params: {
          recipient_ids: [ recipient.id ]
        }

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "PATCH /trips/:trip_id/trip_recipients/:id" do
    let(:user) { create(:user) }
    let(:trip) { create(:trip, user:) }
    let(:recipient) { create(:recipient, user:) }
    let(:trip_recipient) { create(:trip_recipient, trip:, recipient:) }

    context "ログインしている場合" do
      before do
        login_as(user)
      end

      context "未購入の場合" do
        it "購入済みに変更する" do
          patch trip_trip_recipient_path(trip, trip_recipient), params: {
            trip_recipient: {
              purchased: true
            }
          }

          expect(trip_recipient.reload).to be_purchased
        end

        it "旅行詳細画面へリダイレクトする" do
          patch trip_trip_recipient_path(trip, trip_recipient), params: {
            trip_recipient: {
              purchased: true
            }
          }

          expect(response).to redirect_to(trip_path(trip))
        end
      end

      context "購入済みの場合" do
        before do
          trip_recipient.update!(purchased: true)
        end

        it "未購入に変更する" do
          patch trip_trip_recipient_path(trip, trip_recipient), params: {
            trip_recipient: {
              purchased: false
            }
          }

          expect(trip_recipient.reload).not_to be_purchased
        end
      end

      context "他のユーザーの旅行の場合" do
        let(:other_user) { create(:user) }
        let(:other_trip) { create(:trip, user: other_user) }
        let(:other_recipient) { create(:recipient, user: other_user) }
        let(:other_trip_recipient) { create(:trip_recipient, trip: other_trip, recipient: other_recipient, purchased: false) }

        it "購入状況を変更できない" do
          patch trip_trip_recipient_path(other_trip, other_trip_recipient), params: {
            trip_recipient: {
              purchased: true
            }
          }

          expect(response).to have_http_status(:not_found)
          expect(other_trip_recipient.reload).not_to be_purchased
        end
      end
    end

    context "ログインしていない場合" do
      it "購入状況を変更できず、ログイン画面へリダイレクトする" do
        expect {
          patch trip_trip_recipient_path(trip, trip_recipient), params: {
            trip_recipient: {
              purchased: true
            }
          }
        }.not_to change { trip_recipient.reload.purchased }

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "DELETE /trips/:trip_id/trip_recipients/:id" do
    let(:user) { create(:user) }
    let(:trip) { create(:trip, user:) }
    let(:recipient) { create(:recipient, user:) }
    let!(:trip_recipient) { create(:trip_recipient, trip:, recipient:) }

    context "ログインしている場合" do
      before do
        login_as(user)
      end

      context "自分の旅行に紐づく相手の場合" do
        it "自分と相手の紐づけを削除する" do
          expect {
            delete trip_trip_recipient_path(trip, trip_recipient)
        }.to change(TripRecipient, :count).by(-1)
        end

        it "旅行詳細画面へリダイレクトする" do
          delete trip_trip_recipient_path(trip, trip_recipient)

          expect(response).to redirect_to(trip_path(trip))
        end

        it "成功メッセージを設定する" do
          delete trip_trip_recipient_path(trip, trip_recipient)

          expect(flash[:notice]).to eq("相手を外しました")
        end
      end

      context "別の旅行に紐づくTripRecipientを指定した場合" do
        let(:another_trip) { create(:trip, user:) }
        let(:another_recipient) { create(:recipient, user:) }
        let!(:another_trip_recipient) { create(:trip_recipient, trip: another_trip, recipient: another_recipient) }

        it "旅行と相手の紐づけを削除しない" do
          expect {
            delete trip_trip_recipient_path(trip, another_trip_recipient)
          }.not_to change(TripRecipient, :count)
        end
      end

      context "他のユーザーの旅行の場合" do
        let(:other_user) { create(:user) }
        let(:other_trip) { create(:trip, user: other_user) }
        let(:other_recipient) { create(:recipient, user: other_user) }
        let!(:other_trip_recipient) { create(:trip_recipient, trip: other_trip, recipient: other_recipient) }

        it "旅行と相手の紐づけを削除しない" do
          expect {
            delete trip_trip_recipient_path(other_trip, other_trip_recipient)
          }.not_to change(TripRecipient, :count)
        end
      end
    end

    context "ログインしていない場合" do
      it "旅行と相手の紐づけを削除しない" do
        expect {
          delete trip_trip_recipient_path(trip, trip_recipient)
        }.not_to change(TripRecipient, :count)
      end

      it "ログイン画面へリダイレクトする" do
        delete trip_trip_recipient_path(trip, trip_recipient)

        expect(response).to redirect_to(login_path)
      end
    end
  end
end
