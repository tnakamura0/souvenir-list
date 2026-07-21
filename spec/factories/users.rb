FactoryBot.define do
  factory :user do
    name { "テストユーザー" }
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:google_uid) { |n| "google-uid-#{n}" }
    avatar_url { "https://example.com/avatar.png" }
  end
end
