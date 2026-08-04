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

  describe "POST /tags" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      context "正常な値の場合" do
        let(:valid_params) do
          {
            tag: attributes_for(:tag)
          }
        end

        it "タグを作成する" do
          expect {
            post tags_path, params: valid_params
          }.to change(Tag, :count).by(1)
        end

        it "作成したタグがログインユーザーと紐づく" do
          post tags_path, params: valid_params

          expect(Tag.last.user).to eq(user)
        end

        it "タグ一覧画面へリダイレクトする" do
          post tags_path, params: valid_params

          expect(response).to redirect_to(tags_path)
        end

        it "成功時のフラッシュメッセージを設定する" do
          post tags_path, params: valid_params

          expect(flash[:notice]).to eq("タグを作成しました")
        end
      end

      context "不正な値の場合" do
        let(:invalid_params) do
          {
            tag: attributes_for(:tag, name: "")
          }
        end

        it "タグを作成しない" do
          expect {
            post tags_path, params: invalid_params
          }.not_to change(Tag, :count)
        end

        it "タグ一覧画面を再表示する" do
          post tags_path, params: invalid_params

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "失敗時のフラッシュメッセージを設定する" do
          post tags_path, params: invalid_params

          expect(flash[:alert]).to eq("タグを作成できませんでした")
        end
      end
    end

    context "ログインしていない場合" do
      let(:valid_params) do
        {
          tag: attributes_for(:tag)
        }
      end

      it "タグを作成しない" do
        expect {
          post tags_path, params: valid_params
        }.not_to change(Tag, :count)
      end

      it "ログイン画面へリダイレクトする" do
        post tags_path, params: valid_params

        expect(response).to redirect_to(login_path)
      end
    end
  end
end
