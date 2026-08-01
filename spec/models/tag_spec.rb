require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "バリデーション" do
    subject(:tag) { build(:tag) }

    context "すべての属性が有効な場合" do
      it "有効である" do
        expect(tag).to be_valid
      end
    end

    context "nameが空の場合" do
      before { tag.name = nil }

      it "無効である" do
        expect(tag).to be_invalid
        expect(tag.errors[:name]).to be_present
      end
    end

    context "同じユーザーが同名のタグを登録した場合" do
      let(:user) { create(:user) }

      before do
        create(:tag, user:, name: "家族")
      end

      it "無効である" do
        duplicate_tag = build(:tag, user:, name: "家族")

        expect(duplicate_tag).to be_invalid
        expect(duplicate_tag.errors[:name]).to be_present
      end
    end

    context "別のユーザーが同名のタグを登録した場合" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }

      before do
        create(:tag, user:, name: "家族")
      end

      it "有効である" do
        other_users_tag = build(:tag, user: other_user, name: "家族")

        expect(other_users_tag).to be_valid
      end
    end
  end
end
