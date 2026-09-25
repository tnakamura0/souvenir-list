require "rails_helper"

RSpec.describe "PushSubscriptions", type: :request do
  describe "POST /push_subscriptions" do
    let(:user) { create(:user) }

    before do
      login_as(user)
    end

    context "有効なパラメータの場合" do
      let(:valid_params) do
        {
          push_subscription: attributes_for(:push_subscription)
        }
      end

      it "Push Subscriptionが作成される" do
        expect {
          post push_subscriptions_path, params: valid_params
        }.to change(PushSubscription, :count).by(1)
      end

      it "ログインユーザーに紐づいて作成される" do
        post push_subscriptions_path, params: valid_params

        expect(PushSubscription.last.user).to eq(user)
      end

      it "201を返す" do
        post push_subscriptions_path, params: valid_params

        expect(response).to have_http_status(:created)
      end
    end

    context "同じendpointのPush Subscriptionが存在する場合" do
      let!(:push_subscription) do
        create(
          :push_subscription,
          user:,
          p256dh: "old-p256dh-key",
          auth: "old-auth-key"
        )
      end

      let(:valid_params) do
        {
          push_subscription: attributes_for(
            :push_subscription,
            endpoint: push_subscription.endpoint
          )
        }
      end

      it "Push Subscriptionを作成しない" do
        expect {
          post push_subscriptions_path, params: valid_params
        }.not_to change(PushSubscription, :count)
      end

      it "既存のPush Subscriptionを更新する" do
        post push_subscriptions_path, params: valid_params

        push_subscription.reload

        expect(push_subscription.p256dh).to eq("test-p256dh-key")
        expect(push_subscription.auth).to eq("test-auth-key")
      end

      it "200を返す" do
        post push_subscriptions_path, params: valid_params

        expect(response).to have_http_status(:ok)
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_params) do
        {
          push_subscription: attributes_for(:push_subscription, endpoint: nil)
        }
      end

      it "Push Subscriptionを作成しない" do
        expect {
          post push_subscriptions_path, params: invalid_params
        }.not_to change(PushSubscription, :count)
      end

      it "422を返す" do
        post push_subscriptions_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
