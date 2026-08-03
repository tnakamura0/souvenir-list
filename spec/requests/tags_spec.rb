require "rails_helper"

RSpec.describe "Tags", type: :request do
  describe "GET /tags" do
    context "ログインしている場合" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }

      before do
        login_as(user)
      end

      it "タグ一覧画面を表示する" do
        get tags_path

        expect(response).to have_http_status(:ok)
      end

      it "自分が作成したタグを表示して、他のユーザーが作成したタグを表示しない" do
        create(:tag, user:, name: "職場")
        create(:tag, user: other_user, name: "他のユーザーの職場")

        get tags_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("職場")
        expect(response.body).not_to include("他のユーザーの職場")
      end

      it "タグが作成されていない場合はメッセージを表示する" do
        get tags_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("タグがまだ作成されていません")
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトする" do
        get tags_path

        expect(response).to redirect_to(login_path)
      end
    end
  end
end
