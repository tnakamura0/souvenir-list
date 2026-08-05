require "rails_helper"

RSpec.describe Recipient, type: :model do
  describe "バリデーション" do
    subject(:recipient) { build(:recipient) }

    context "すべての属性が有効な場合" do
      it "有効である" do
        expect(recipient).to be_valid
      end
    end

    context "nameが空の場合" do
      before { recipient.name = nil }

      it "無効である" do
        expect(recipient).to be_invalid
        expect(recipient.errors[:name]).to be_present
      end
    end

    context "kindが空の場合" do
      before { recipient.kind = nil }

      it "無効である" do
        expect(recipient).to be_invalid
        expect(recipient.errors[:kind]).to be_present
      end
    end

    context "kindがindividualでpeople_countが空の場合" do
      before do
        recipient.kind = :individual
        recipient.people_count = nil
      end

      it "people_countに1が設定され、有効である" do
        expect(recipient).to be_valid
        expect(recipient.people_count).to eq(1)
      end
    end

    context "kindがgroupでpeople_countが空の場合" do
      before do
        recipient.kind = :group
        recipient.people_count = nil
      end

      it "無効である" do
        expect(recipient).to be_invalid
        expect(recipient.errors[:people_count]).to be_present
      end
    end
  end

  describe ".with_tag" do
    let(:user) { create(:user) }
    let(:tag) { create(:tag, user:) }

    it "指定したタグが関連付いている相手だけを返す" do
      matching_recipient = create(:recipient, user:)
      other_recipient = create(:recipient, user:)

      matching_recipient.tags << tag

      expect(described_class.with_tag(tag.id)).to contain_exactly(
        matching_recipient
      )
    end
  end
end
