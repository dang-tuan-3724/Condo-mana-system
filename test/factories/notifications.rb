FactoryBot.define do
  factory :notification do
    association :user
    message { Faker::Lorem.sentence }
    status { %w[unread read].sample }
    category { %w[booking admin system].sample }
    reference_id { Faker::Number.number(digits: 2) }
    reference_type { "Booking" }
  end
end
