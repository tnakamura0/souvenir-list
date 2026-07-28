require "rails_helper"

RSpec.describe "Recipients", type: :request do
  describe "GET /recipients" do
    context "ログインしている場合" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }

      before do
        login_as(user)
      end

      it "相手一覧画面を表示する" do
        get recipients_path

        expect(response).to have_http_status(:ok)
      end

      it "自分が登録した相手を表示して、他のユーザーが登録した相手を表示しない" do
        create(:recipient, user:, name: "自分の友人")
        create(:recipient, user: other_user, name: "他のユーザーの友人")

        get recipients_path

        expect(response.body).to include("自分の友人")
        expect(response.body).not_to include("他のユーザーの友人")
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトする" do
        get recipients_path

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /recipients/new" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      it "相手登録画面を表示する" do
        get new_recipient_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトする" do
        get new_recipient_path

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "POST /recipients" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      context "正常な値の場合" do
        let(:valid_params) do
          {
            recipient: attributes_for(:recipient)
          }
        end

        it "相手を作成する" do
          expect {
            post recipients_path, params: valid_params
          }.to change(Recipient, :count).by(1)
        end

        it "作成した相手がログインユーザーと紐づく" do
          post recipients_path, params: valid_params

          expect(Recipient.last.user).to eq(user)
        end

        it "相手一覧画面へリダイレクトする" do
          post recipients_path, params: valid_params

          expect(response).to redirect_to(recipients_path)
        end
      end

      context "不正な値の場合" do
        let(:invalid_params) do
          {
            recipient: attributes_for(:recipient, name: nil)
          }
        end

        it "相手を作成しない" do
          expect {
            post recipients_path, params: invalid_params
          }.not_to change(Recipient, :count)
        end

        it "相手登録画面を再表示する" do
          post recipients_path, params: invalid_params

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "ログインしていない場合" do
      let(:valid_params) do
        {
          recipient: attributes_for(:recipient)
        }
      end

      it "相手を作成せずにログイン画面へリダイレクトする" do
        expect {
          post recipients_path, params: valid_params
        }.not_to change(Recipient, :count)

        expect(response).to redirect_to(login_path)
      end
    end
  end
end
