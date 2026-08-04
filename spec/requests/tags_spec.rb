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

  describe "GET /tags/:id/edit" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      context "自分が作成したタグを指定した場合" do
        let(:tag) { create(:tag, user:) }

        it "タグ編集画面を表示する" do
          get edit_tag_path(tag)

          expect(response).to have_http_status(:ok)
        end
      end

      context "他のユーザーが作成したタグを指定した場合" do
        let(:other_user) { create(:user) }
        let(:tag) { create(:tag, user: other_user) }

        it "タグ編集画面を表示しない" do
          get edit_tag_path(tag)

          expect(response).to have_http_status(:not_found)
        end
      end

      context "存在しないタグを指定した場合" do
        it "タグ編集画面を表示しない" do
          get edit_tag_path(id: 0)

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "ログインしていない場合" do
      let(:tag) { create(:tag) }

      it "ログイン画面へリダイレクトする" do
        get edit_tag_path(tag)

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "PATCH /tags/:id" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      context "自分が作成したタグを指定した場合" do
        let(:tag) { create(:tag, user:, name: "更新前の名前") }

        context "正常な値の場合" do
          let(:valid_params) do
            {
              tag: {
                name: "更新後の名前"
              }
            }
          end

          it "タグを更新できる" do
            expect {
              patch tag_path(tag), params: valid_params
            }.to change { tag.reload.name }.from("更新前の名前").to("更新後の名前")
          end

          it "タグ一覧画面へリダイレクトする" do
            patch tag_path(tag), params: valid_params

            expect(response).to redirect_to(tags_path)
          end

          it "成功時のフラッシュメッセージを設定する" do
            patch tag_path(tag), params: valid_params

            expect(flash[:notice]).to eq("タグを更新しました")
          end
        end

        context "不正な値の場合" do
          let(:invalid_params) do
            {
              tag: {
                name: ""
              }
            }
          end

          it "タグを更新できない" do
            expect {
              patch tag_path(tag), params: invalid_params
            }.not_to change { tag.reload.name }
          end

          it "422ステータスを返す" do
            patch tag_path(tag), params: invalid_params

            expect(response).to have_http_status(:unprocessable_content)
          end

          it "失敗時のフラッシュメッセージを設定する" do
            patch tag_path(tag), params: invalid_params

            expect(flash[:alert]).to eq("タグを更新できませんでした")
          end
        end
      end

      context "他のユーザーが作成したタグを指定した場合" do
        let(:other_user) { create(:user) }
        let(:tag) { create(:tag, user: other_user) }
        let(:valid_params) do
          {
            tag: {
              name: "更新後の名前"
            }
          }
        end

        it "タグを更新できない" do
          expect {
            patch tag_path(tag), params: valid_params
          }.not_to change { tag.reload.name }
        end

        it "404を返す" do
          patch tag_path(tag), params: valid_params

          expect(response).to have_http_status(:not_found)
        end
      end

      context "存在しないタグを指定した場合" do
        it "タグを更新できない" do
          patch tag_path(id: 0), params: {
            tag: {
              name: "更新後の名前"
            }
          }

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "ログインしていない場合" do
      let(:tag) { create(:tag) }

      it "ログイン画面へリダイレクトする" do
        patch tag_path(tag), params: {
          tag: {
            name: "更新後の名前"
          }
        }

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "DELETE /tags/:id" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      context "自分が作成したタグを指定した場合" do
        let(:tag) { create(:tag, user:) }

        it "タグを削除できる" do
          expect {
            delete tag_path(tag)
          }.to change {
            Tag.exists?(tag.id)
          }.from(true).to(false)
        end

        it "タグ一覧画面へリダイレクトする" do
          delete tag_path(tag)

          expect(response).to redirect_to(tags_path)
        end

        it "成功時のフラッシュメッセージが表示される" do
          delete tag_path(tag)

          expect(flash[:notice]).to eq("タグを削除しました")
        end
      end

      context "他のユーザーのタグを指定した場合" do
        let(:other_user) { create(:user) }
        let!(:tag) { create(:tag, user: other_user) }

        it "タグを削除できない" do
          expect {
            delete tag_path(tag)
          }.not_to change(Tag, :count)

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "ログインしていない場合" do
      let(:tag) { create(:tag) }

      it "ログイン画面へリダイレクトする" do
        delete tag_path(tag)

        expect(response).to redirect_to(login_path)
      end
    end
  end
end
