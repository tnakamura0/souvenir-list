FactoryBot.define do
  factory :trip do
    association :user
    name { "名古屋旅行" }
    destination { "名古屋、岐阜" }
    departure_date { "2026-07-23" }
    return_date { "2026-07-25" }
  end
end
