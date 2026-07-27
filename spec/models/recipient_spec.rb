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

    context "people_countが空の場合" do
      before { recipient.people_count = nil }

      it "無効である" do
        expect(recipient).to be_invalid
        expect(recipient.errors[:people_count]).to be_present
      end
    end
  end
end
