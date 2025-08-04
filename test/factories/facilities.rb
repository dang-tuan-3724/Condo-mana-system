FactoryBot.define do
  factory :facility do
    name { Faker::Lorem.words(number: 2).join(" ").titleize }
    description { Faker::Lorem.sentence }
    association :condo
    availability_schedule {
      days = %w[monday tuesday wednesday thursday friday saturday sunday]
      slots = (7..20).map { |h| "#{h.to_s.rjust(2, '0')}:00-#{(h+1).to_s.rjust(2, '0')}:00" }
      days.map { |d| [ d, slots ] }.to_h
    }
  end
end
