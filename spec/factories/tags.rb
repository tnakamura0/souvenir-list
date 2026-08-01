FactoryBot.define do
  factory :tag do
    association :user
    name { "家族" }
  end
end
