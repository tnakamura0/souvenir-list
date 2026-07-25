FactoryBot.define do
  factory :trip do
    association :user
    name { "名古屋旅行" }
    destination { "名古屋、岐阜" }
    departure_date { Date.new(2026, 7, 23) }
    return_date { Date.new(2026, 7, 25) }
  end
end
