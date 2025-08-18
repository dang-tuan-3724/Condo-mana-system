FactoryBot.define do
  factory :booking do
    association :user
    association :facility
    purpose { Faker::Lorem.sentence(word_count: 3) }
    status { %w[pending approved rejected].sample }
    approved_by { nil }

    trait :approved do
      status { "approved" }
      association :approved_by, factory: :user, strategy: :build, role: "operation_admin"
    end
  end
end
