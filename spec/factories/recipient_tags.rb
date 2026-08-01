FactoryBot.define do
  factory :recipient_tag do
    association :recipient
    association :tag
  end
end
