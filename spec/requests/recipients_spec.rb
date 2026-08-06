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

      it "タグが指定されていない場合は自分の相手を全て表示する" do
        recipient1 = create(:recipient, user:, name: "母親")
        recipient2 = create(:recipient, user:, name: "職場の同僚")

        get recipients_path

        expect(response.body).to include(recipient1.name)
        expect(response.body).to include(recipient2.name)
      end

      it "選択したタグが関連付いている相手だけを表示する" do
        family_tag = create(:tag, user:, name: "家族")

        family_recipient = create(:recipient, user:, name: "母親")
        coworker_recipient = create(:recipient, user:, name: "職場の同僚")

        family_recipient.tags << family_tag

        get recipients_path, params: { tag_id: family_tag.id }

        expect(response.body).to include(family_recipient.name)
        expect(response.body).not_to include(coworker_recipient.name)
      end

      it "他のユーザーが所有するタグを指定しても他人の相手を表示しない" do
        own_recipient = create(:recipient, user:, name: "自分の相手")

        other_tag = create(:tag, user: other_user)
        other_recipient = create(:recipient, user: other_user, name: "他人の相手")
        other_recipient.tags << other_tag

        get recipients_path, params: { tag_id: other_tag.id }

        expect(response.body).to include(own_recipient.name)
        expect(response.body).not_to include(other_recipient.name)
      end

      it "相手に関連付いているタグを表示する" do
        recipient = create(:recipient, user:)
        tag = create(:tag, user:, name: "家族")

        create(:recipient_tag, recipient:, tag:)

        get recipients_path

        expect(response.body).to include("家族")
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

        it "選択したタグを相手に関連付ける" do
          tags = create_list(:tag, 2, user:)

          post recipients_path, params: {
              recipient: attributes_for(:recipient).merge(
                tag_ids: tags.map(&:id)
              )
            }

          recipient = user.recipients.last

          expect(recipient.tags).to contain_exactly(*tags)
        end

        it "自分のタグだけを相手に関連付ける" do
          own_tag = create(:tag, user:)
          other_user = create(:user)
          other_tag = create(:tag, user: other_user)

          post recipients_path, params: {
            recipient: attributes_for(:recipient).merge(
              tag_ids: [ own_tag.id, other_tag.id ]
            )
          }

          recipient = user.recipients.last

          expect(response).to redirect_to(recipients_path)
          expect(recipient.tags).to contain_exactly(own_tag)
        end

        it "新しいタグ名が入力されるとタグを作成して相手に関連付ける" do
          expect {
            post recipients_path, params: {
              recipient: attributes_for(:recipient).merge(
                new_tag_name: "家族"
              )
            }
          }.to change(Tag, :count).by(1).and change(RecipientTag, :count).by(1)

          recipient = user.recipients.last
          tag = user.tags.find_by(name: "家族")

          expect(recipient.tags).to include(tag)
        end

        it "同名のタグが既にある場合は既存タグを関連付ける" do
          tag = create(:tag, user:, name: "家族")

          expect {
            post recipients_path, params: {
              recipient: attributes_for(:recipient).merge(
                new_tag_name: "家族"
              )
            }
          }.not_to change(Tag, :count)

          recipient = user.recipients.last

          expect(recipient.tags).to contain_exactly(tag)
        end

        it "既存タグと新しいタグの両方を相手に関連付ける" do
          existing_tag = create(:tag, user:, name: "友人")

          post recipients_path, params: {
            recipient: attributes_for(:recipient).merge(
              tag_ids: [ existing_tag.id ],
              new_tag_name: "旅行仲間"
            )
          }

          recipient = user.recipients.last

          expect(recipient.tags.pluck(:name)).to contain_exactly("友人", "旅行仲間")
        end

        it "新しいタグ名が空の場合はタグを作成しない" do
          expect {
            post recipients_path, params: {
              recipient: attributes_for(:recipient).merge(
                new_tag_name: ""
              )
            }
          }.not_to change(Tag, :count)

          expect(user.recipients.last.tags).to be_empty
        end

        it "新しいタグ名の前後の空白を除去して作成する" do
          post recipients_path, params: {
            recipient: attributes_for(:recipient).merge(
              new_tag_name: "  家族  "
            )
          }

          expect(user.tags).to exist(name: "家族")
          expect(user.tags).not_to exist(name: "  家族  ")
        end

        it "他のユーザーに同名タグがある場合は自分のタグとして新規作成する" do
          other_user = create(:user)
          create(:tag, user: other_user, name: "家族")

          expect {
            post recipients_path, params: {
              recipient: attributes_for(:recipient).merge(
                new_tag_name: "家族"
              )
            }
          }.to change(user.tags, :count).by(1)

          recipient = user.recipients.last

          expect(recipient.tags.first.user).to eq(user)
          expect(recipient.tags.first.name).to eq("家族")
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

  describe "GET /recipients/:id/edit" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      context "自分が作成した相手を指定した場合" do
        let(:recipient) { create(:recipient, user:) }

        it "相手編集画面を表示する" do
          get edit_recipient_path(recipient)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include(recipient.name)
        end
      end

      context "他ユーザーが作成した相手を指定した場合" do
        let(:other_user) { create(:user) }
        let(:recipient) { create(:recipient, user: other_user) }

        it "相手編集画面を表示しない" do
          get edit_recipient_path(recipient)

          expect(response).to have_http_status(:not_found)
        end
      end

      context "存在しない相手を指定した場合" do
        it "相手編集画面を表示しない" do
          get edit_recipient_path(id: 0)

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "ログインしていない場合" do
      let(:recipient) { create(:recipient) }

      it "ログイン画面へリダイレクトする" do
        get edit_recipient_path(recipient)

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("ログインしてください")
      end
    end
  end

  describe "PATCH /recipients/:id" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      context "自分が作成した相手を指定した場合" do
        let(:recipient) { create(:recipient, user:, name: "更新前の名前") }

        context "正常な値の場合" do
          it "相手を更新できる" do
            expect {
              patch recipient_path(recipient), params: {
                recipient: {
                  name: "更新後の名前"
                }
              }
            }.to change { recipient.reload.name }.from("更新前の名前").to("更新後の名前")
          end

          it "相手一覧画面へリダイレクトする" do
            patch recipient_path(recipient), params: {
              recipient: {
                name: "更新後の名前"
              }
            }

            expect(response).to redirect_to(recipients_path)
            expect(flash[:notice]).to eq("相手を更新しました")
          end

          it "相手に関連付けるタグを変更する" do
            old_tag = create(:tag, user:)
            new_tag = create(:tag, user:)
            recipient = create(:recipient, user:, tags: [ old_tag ])

            patch recipient_path(recipient), params: {
              recipient: {
                name: recipient.name,
                kind: recipient.kind,
                people_count: recipient.people_count,
                memo: recipient.memo,
                tag_ids: [ new_tag.id ]
              }
            }

            expect(recipient.reload.tags).to contain_exactly(new_tag)
          end

          it "相手に関連付いているタグをすべて解除する" do
            tag = create(:tag, user:)
            recipient = create(:recipient, user:, tags: [ tag ])

            patch recipient_path(recipient), params: {
              recipient: {
                name: recipient.name,
                kind: recipient.kind,
                people_count: recipient.people_count,
                memo: recipient.memo,
                tag_ids: [ "" ]
              }
            }

            expect(recipient.reload.tags).to be_empty
          end

          it "他のユーザーのタグを相手に関連付けず、自分のタグだけ更新する" do
            old_tag = create(:tag, user:, name: "家族")
            own_tag = create(:tag, user:, name: "職場")
            other_user = create(:user)
            other_tag = create(:tag, user: other_user, name: "友人")
            recipient = create(:recipient, user:, tags: [ old_tag ])

            patch recipient_path(recipient), params: {
              recipient: attributes_for(:recipient).merge(
                tag_ids: [ own_tag.id, other_tag.id ]
              )
            }

            expect(response).to redirect_to(recipients_path)
            expect(recipient.reload.tags).to contain_exactly(own_tag)
          end

          it "新しいタグ名が入力されるとタグを作成して相手に追加する" do
            expect {
              patch recipient_path(recipient), params: {
                recipient: {
                  name: recipient.name,
                  kind: recipient.kind,
                  people_count: recipient.people_count,
                  memo: recipient.memo,
                  new_tag_name: "職場"
                }
              }
            }.to change(Tag, :count).by(1).and change(RecipientTag, :count).by(1)

            expect(recipient.reload.tags.pluck(:name)).to include("職場")
          end
        end

        context "不正な値の場合" do
          it "相手を更新できない" do
            expect {
              patch recipient_path(recipient), params: {
                recipient: {
                  name: ""
                }
              }
            }.not_to change { recipient.reload.name }
          end

          it "相手編集画面を再表示する" do
            patch recipient_path(recipient), params: {
              recipient: {
                name: ""
              }
            }

            expect(response).to have_http_status(:unprocessable_content)
            expect(flash[:alert]).to eq("相手を更新できませんでした")
          end
        end
      end

      context "他ユーザーが作成した相手を指定した場合" do
        let(:other_user) { create(:user) }
        let(:recipient) { create(:recipient, user: other_user) }

        it "相手を更新できない" do
          expect {
            patch recipient_path(recipient), params: {
              recipient: {
                name: "更新後の名前"
              }
            }
          }.not_to change { recipient.reload.name }

          expect(response).to have_http_status(:not_found)
        end
      end

      context "存在しない相手を指定した場合" do
        it "相手を更新できない" do
          patch recipient_path(id: 0), params: {
            recipient: {
              name: "更新後の名前"
            }
          }

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "ログインしていない場合" do
      let(:recipient) { create(:recipient) }

      it "ログイン画面へリダイレクトする" do
        patch recipient_path(recipient), params: {
          recipient: {
            name: "更新後の名前"
          }
        }

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("ログインしてください")
      end
    end
  end

  describe "DELETE /recipients/:id" do
    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      context "自分が作成した相手を指定した場合" do
        let!(:recipient) { create(:recipient, user:) }

        it "相手を削除できる" do
          expect {
            delete recipient_path(recipient)
          }.to change {
            Recipient.exists?(recipient.id)
          }.from(true).to(false)

          expect(response).to redirect_to(recipients_path)
          expect(flash[:notice]).to eq("相手を削除しました")
        end
      end

      context "他のユーザーの相手を指定した場合" do
        let(:other_user) { create(:user) }
        let!(:recipient) { create(:recipient, user: other_user) }

        it "相手を削除できない" do
          expect {
            delete recipient_path(recipient)
          }.not_to change(Recipient, :count)

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "ログインしていない場合" do
      let!(:recipient) { create(:recipient) }
      it "相手を削除せずにログイン画面へリダイレクトする" do
        expect {
          delete recipient_path(recipient)
        }.not_to change(Recipient, :count)

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("ログインしてください")
      end
    end
  end
end
