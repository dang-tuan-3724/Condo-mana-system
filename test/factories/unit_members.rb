FactoryBot.define do
  factory :unit_member do
    association :unit
    association :user
  end
end
