
require "rails_helper"

RSpec.describe WebPushSender do
  let!(:subscription) { create(:push_subscription) }

  let(:title) { "OmiMemo" }
  let(:body) { "プッシュ通知のテストです" }

  let(:public_key) { "test-public-key" }
  let(:private_key) { "test-private-key" }

  subject(:send_push) do
    described_class.call(subscription:, title:, body:)
  end

  before do
    credentials = Rails.application.credentials

    allow(credentials).to receive(:dig)
      .with(:vapid, :public_key)
      .and_return(public_key)

    allow(credentials).to receive(:dig)
      .with(:vapid, :private_key)
      .and_return(private_key)
  end

  describe ".call" do
    context "送信に成功した場合" do
      it "正しい引数でWeb Pushを送信する" do
        expect(WebPush).to receive(:payload_send).with(
          message: { title:, body: }.to_json,
          endpoint: subscription.endpoint,
          p256dh: subscription.p256dh,
          auth: subscription.auth,
          vapid: {
            subject: "https://omimemo.com",
            public_key: public_key,
            private_key: private_key
          },
          ttl: 3600,
          open_timeout: 5,
          read_timeout: 5
        )

        send_push
      end
    end

    context "Subscriptionが失効している場合" do
      before do
        response = Net::HTTPGone.new("1.1", "410", "Gone")
        allow(response).to receive(:body).and_return("")

        allow(WebPush).to receive(:payload_send).and_raise(
          WebPush::ExpiredSubscription.new(
            response, "push.example.com"
          )
        )
      end

      it "Subscriptionを削除する" do
        expect { send_push }
          .to change(PushSubscription, :count).by(-1)
      end
    end

    context "Subscriptionが存在しない場合" do
      before do
        response = Net::HTTPNotFound.new("1.1", "404", "Not Found")
        allow(response).to receive(:body).and_return("")

        allow(WebPush).to receive(:payload_send).and_raise(
          WebPush::InvalidSubscription.new(
            response, "push.example.com"
          )
        )
      end

      it "Subscriptionを削除する" do
        expect { send_push }
          .to change(PushSubscription, :count).by(-1)
      end
    end

    context "送信回数制限が発生した場合" do
      before do
        response = Net::HTTPTooManyRequests.new(
          "1.1", "429", "Too Many Requests"
        )
        allow(response).to receive(:body).and_return("")

        allow(WebPush).to receive(:payload_send).and_raise(
          WebPush::TooManyRequests.new(
            response, "push.example.com"
          )
        )
      end

      it "Subscriptionを削除せずログに記録する" do
        expect(Rails.logger).to receive(:warn)
          .with(/status=429/)

        expect { send_push }
          .not_to change(PushSubscription, :count)
      end
    end

    context "Push Serviceで一時的な障害が発生した場合" do
      before do
        response = Net::HTTPServiceUnavailable.new(
          "1.1", "503", "Service Unavailable"
        )
        allow(response).to receive(:body).and_return("")

        allow(WebPush).to receive(:payload_send).and_raise(
          WebPush::PushServiceError.new(
            response, "push.example.com"
          )
        )
      end

      it "Subscriptionを削除しない" do
        expect { send_push }
          .not_to change(PushSubscription, :count)
      end
    end

    context "ネットワークタイムアウトが発生した場合" do
      before do
        allow(WebPush).to receive(:payload_send)
          .and_raise(Net::ReadTimeout)
      end

      it "Subscriptionを削除せずログに記録する" do
        expect(Rails.logger).to receive(:warn)
          .with(/Web Push network error/)

        expect { send_push }
          .not_to change(PushSubscription, :count)
      end
    end
  end
end
