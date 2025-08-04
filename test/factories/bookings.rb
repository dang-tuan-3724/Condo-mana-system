FactoryBot.define do
  factory :booking do
    association :user
    association :facility
    start_time { Faker::Time.forward(days: 3, period: :morning) }
    end_time { start_time + Faker::Number.between(from: 1, to: 3).hours }
    purpose { Faker::Lorem.sentence(word_count: 3) }
    status { %w[pending approved rejected].sample }
    approved_by { nil }

    trait :approved do
      status { "approved" }
      association :approved_by, factory: :user, strategy: :build, role: "operation_admin"
    end
  end
end
