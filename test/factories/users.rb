FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 }
    role { %w[house_member house_owner operation_admin].sample }
    association :condo

    trait :super_admin do
      role { "super_admin" }
      email { "superadmin@example.com" }
      first_name { "Quản trị" }
      last_name { "Hệ thống" }
    end

    trait :operation_admin do
      role { "operation_admin" }
      email { "operation@example.com" }
      first_name { "Vận hành" }
      last_name { "Tòa nhà" }
    end

    trait :house_owner do
      role { "house_owner" }
      email { "owner@example.com" }
      first_name { "Chủ" }
      last_name { "Nhà" }
    end

    trait :house_member do
      role { "house_member" }
      email { "member@example.com" }
      first_name { "Thành viên" }
      last_name { "Gia đình" }
    end
  end
end
