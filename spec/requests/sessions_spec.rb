require "rails_helper"

RSpec.describe "Sessions", type: :request do
  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.mock_auth.delete(:google_oauth2)
  end

  describe "GET /login" do
    it "ログイン画面を表示する" do
      get login_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /auth/google_oauth2" do
    context "Google認証に成功した場合" do
      before do
        mock_google_auth
      end

      it "ユーザーを作成してルートページへリダイレクトする" do
        expect {
          post "/auth/google_oauth2"
          follow_redirect!
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(root_path)
      end

      it "ログイン状態になる" do
        post "/auth/google_oauth2"
        follow_redirect!

        get root_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "ユーザーを保存できなかった場合" do
      before do
        mock_google_auth

        invalid_user = build(:user, name: nil)

        allow(User)
          .to receive(:find_or_create_from_auth_hash)
          .and_return(invalid_user)
      end

      it "ログイン画面へリダイレクトする" do
        post "/auth/google_oauth2"
        follow_redirect!

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /auth/failure" do
    it "ログイン画面へリダイレクトする" do
      get "/auth/failure"

      expect(response).to redirect_to(login_path)
    end
  end

  describe "DELETE /logout" do
    before do
      mock_google_auth

      post "/auth/google_oauth2"
      follow_redirect!
    end

    it "ログアウトしてログイン画面へリダイレクトする" do
      delete logout_path

      expect(response).to redirect_to(login_path)
      expect(response).to have_http_status(:see_other)
    end

    it "ログイン状態を解除する" do
      delete logout_path

      get root_path

      expect(response).to redirect_to(login_path)
    end
  end

  describe "認証が必要なページへのアクセス" do
    it "未ログインの場合はログイン画面へリダイレクトする" do
      get root_path

      expect(response).to redirect_to(login_path)
    end
  end

  def mock_google_auth
    OmniAuth.config.mock_auth[:google_oauth2] =
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "123456789",
        info: {
          name: "テストユーザー",
          email: "test@example.com",
          image: "https://example.com/avatar.png"
        }
      )
  end
end
