require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    subject(:user) { build(:user) }

    context "すべての属性が有効な場合" do
      it "有効である" do
        expect(user).to be_valid
      end
    end

    context "nameが空の場合" do
      before { user.name = nil }

      it "無効である" do
        expect(user).to be_invalid
        expect(user.errors[:name]).to be_present
      end
    end

    context "emailが空の場合" do
      before { user.email = nil }

      it "無効である" do
        expect(user).to be_invalid
        expect(user.errors[:email]).to be_present
      end
    end

    context "emailが重複している場合" do
      before do
        create(:user, email: user.email)
      end

      it "無効である" do
        expect(user).to be_invalid
        expect(user.errors[:email]).to be_present
      end
    end

    context "google_uidが空の場合" do
      before { user.google_uid = nil }

      it "無効である" do
        expect(user).to be_invalid
        expect(user.errors[:google_uid]).to be_present
      end
    end

    context "google_uidが重複している場合" do
      before do
        create(:user, google_uid: user.google_uid)
      end

      it "無効である" do
        expect(user).to be_invalid
        expect(user.errors[:google_uid]).to be_present
      end
    end
  end

  describe ".find_or_create_from_auth_hash" do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        uid: "google-uid-123",
        info: {
          name: "認証ユーザー",
          email: "auth-user@example.com",
          image: "https://example.com/auth-avatar.png"
        }
      )
    end

    context "同じgoogle_uidのユーザーが存在しない場合" do
      it "ユーザーを新規作成する" do
        expect do
          described_class.find_or_create_from_auth_hash(auth_hash)
        end.to change(described_class, :count).by(1)
      end

      it "認証情報を保存する" do
        user = described_class.find_or_create_from_auth_hash(auth_hash)

        expect(user).to have_attributes(
          name: "認証ユーザー",
          email: "auth-user@example.com",
          google_uid: "google-uid-123",
          avatar_url: "https://example.com/auth-avatar.png"
        )
      end
    end

    context "同じgoogle_uidのユーザーが存在する場合" do
      let!(:existing_user) do
        create(
          :user,
          name: "変更前の名前",
          email: "before@example.com",
          google_uid: "google-uid-123",
          avatar_url: "https://example.com/before.png"
        )
      end

      it "ユーザーを新規作成しない" do
        expect do
          described_class.find_or_create_from_auth_hash(auth_hash)
        end.not_to change(described_class, :count)
      end

      it "既存のユーザーを返す" do
        user = described_class.find_or_create_from_auth_hash(auth_hash)

        expect(user).to eq(existing_user)
      end

      it "既存ユーザーの情報を最新の認証情報で更新する" do
        user = described_class.find_or_create_from_auth_hash(auth_hash)

        expect(user).to have_attributes(
          name: "認証ユーザー",
          email: "auth-user@example.com",
          google_uid: "google-uid-123",
          avatar_url: "https://example.com/auth-avatar.png"
        )
      end
    end
  end
end
