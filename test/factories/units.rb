FactoryBot.define do
  factory :unit do
    unit_number { "#{Faker::Alphanumeric.alpha(number: 1).upcase}-#{Faker::Number.number(digits: 3)}" }
    floor { Faker::Number.between(from: 1, to: 30) }
    size { Faker::Number.decimal(l_digits: 2, r_digits: 1) }
    association :condo
    association :house_owner, factory: :user, role: "house_owner"
  end
end
