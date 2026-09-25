FactoryBot.define do
  factory :push_subscription do
    association :user

    sequence(:endpoint) { |n| "https://example.com/push/#{n}" }
    p256dh { "test-p256dh-key" }
    auth { "test-auth-key" }
  end
end
