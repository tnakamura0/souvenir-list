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
end
