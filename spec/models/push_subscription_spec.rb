require "rails_helper"

RSpec.describe PushSubscription, type: :model do
  describe "バリデーション" do
    subject(:push_subscription) { build(:push_subscription) }

    context "全ての属性が有効な場合" do
      it "有効である" do
        expect(push_subscription).to be_valid
      end
    end

    context "endpointが空の場合" do
      before { push_subscription.endpoint = nil }

      it "無効である" do
        expect(push_subscription).to be_invalid
        expect(push_subscription.errors[:endpoint]).to be_present
      end
    end

    context "endpointが重複している場合" do
      before do
        create(:push_subscription, endpoint: push_subscription.endpoint)
      end

      it "無効である" do
        expect(push_subscription).to be_invalid
        expect(push_subscription.errors[:endpoint]).to be_present
      end
    end

    context "p256dhが空の場合" do
      before { push_subscription.p256dh = nil }

      it "無効である" do
        expect(push_subscription).to be_invalid
        expect(push_subscription.errors[:p256dh]).to be_present
      end
    end

    context "authが空の場合" do
      before { push_subscription.auth = nil }

      it "無効である" do
        expect(push_subscription).to be_invalid
        expect(push_subscription.errors[:auth]).to be_present
      end
    end
  end
end
