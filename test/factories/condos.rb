FactoryBot.define do
  factory :condo do
    name { "Tòa #{Faker::Lorem.word.capitalize} - #{Faker::Company.name}" }
    address { Faker::Address.full_address }
    configuration {
      {
        floors: Faker::Number.between(from: 10, to: 40),
        amenities: Faker::Lorem.words(number: 3)
      }
    }
  end
end
