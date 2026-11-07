
class WebPushSender
  def self.call(subscription:, title:, body:)
    new(subscription:, title:, body:).call
  end

  def initialize(subscription:, title:, body:)
    @subscription = subscription
    @title = title
    @body = body
  end

  def call
    WebPush.payload_send(**push_options)
  rescue WebPush::ExpiredSubscription,
         WebPush::InvalidSubscription
    @subscription.destroy!
  rescue WebPush::ResponseError => e
    Rails.logger.warn(
      "Web Push failed: subscription_id=#{@subscription.id}, " \
      "status=#{e.response.code}"
    )
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => e
    Rails.logger.warn(
      "Web Push network error: subscription_id=#{@subscription.id}, " \
      "error=#{e.class}"
    )
  end

  private

  def push_options
    {
      message: { title: @title, body: @body }.to_json,
      endpoint: @subscription.endpoint,
      p256dh: @subscription.p256dh,
      auth: @subscription.auth,
      vapid: {
        subject: "https://omimemo.com",
        public_key: vapid_public_key,
        private_key: vapid_private_key
      },
      ttl: 3600,
      open_timeout: 5,
      read_timeout: 5
    }
  end

  def vapid_public_key
    Rails.application.credentials.dig(:vapid, :public_key)
  end

  def vapid_private_key
    Rails.application.credentials.dig(:vapid, :private_key)
  end
end
