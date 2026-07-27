FactoryBot.define do
  factory :recipient do
    association :user
    name { "母親" }
    kind { :individual }
    people_count { 1 }
    memo { "甘いものが好き" }

    trait :group do
      name { "職場" }
      kind { :group }
      people_count { 5 }
    end
  end
end
