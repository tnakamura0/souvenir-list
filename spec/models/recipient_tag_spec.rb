require "rails_helper"

RSpec.describe RecipientTag, type: :model do
  describe "バリデーション" do
    let(:user) { create(:user) }
    let(:recipient) { create(:recipient, user:) }
    let(:tag) { create(:tag, user:) }

    context "すべての属性が有効な場合" do
      it "有効である" do
        recipient_tag = build(:recipient_tag, recipient:, tag:)

        expect(recipient_tag).to be_valid
      end
    end

    context "同じrecipientとtagの組み合わせが既に存在する場合" do
      before do
        create(:recipient_tag, recipient:, tag:)
      end

      it "無効である" do
        duplicate_recipient_tag = build(:recipient_tag, recipient:, tag:)

        expect(duplicate_recipient_tag).to be_invalid

        # モデルで以下のように定義しているので、エラーがrecipient_idに追加される
        # validates :recipient_id, uniqueness: { scope: :tag_id }
        expect(duplicate_recipient_tag.errors[:recipient_id]).to be_present
      end
    end
  end
end
