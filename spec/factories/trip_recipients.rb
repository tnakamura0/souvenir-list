FactoryBot.define do
  factory :trip_recipient do
    association :trip
    association :recipient
    purchased { false }
  end
end
