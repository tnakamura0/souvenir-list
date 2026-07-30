require "rails_helper"

RSpec.describe TripRecipient, type: :model do
  let(:user) { create(:user) }
  let(:trip) { create(:trip, user:) }
  let(:recipient) { create(:recipient, user:) }

  describe "バリデーション" do
    subject(:trip_recipient) do
      build(:trip_recipient, trip:, recipient:)
    end

    context "すべての属性が有効な場合" do
      it "有効である" do
        expect(trip_recipient).to be_valid
      end
    end

    context "同じ旅行に同じ相手が既に追加されている場合" do
      before do
        create(:trip_recipient, trip:, recipient:)
      end

      it "無効である" do
        expect(trip_recipient).to be_invalid
        expect(trip_recipient.errors[:recipient_id]).to be_present
      end
    end
  end

  describe "デフォルト値" do
    it "purchasedがfalseである" do
      trip_recipient = create(:trip_recipient, trip:, recipient:)

      expect(trip_recipient.purchased).to be(false)
    end
  end
end
