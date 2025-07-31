# db/seeds.rb
require 'securerandom'

# Xóa toàn bộ dữ liệu hiện có để tránh trùng lặp
puts "Xóa dữ liệu cũ..."
User.delete_all
Condo.delete_all
Unit.delete_all
UnitMember.delete_all
Facility.delete_all
Booking.delete_all
Notification.delete_all

# Đặt lại sequence (nếu cần, nhưng không cần thiết với uuid)
ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end

# Tạo condos
puts "Tạo condos..."
condo1 = Condo.create!(
  name: "Tòa A - Vinhomes",
  address: "123 Nguyễn Huệ, Quận 1, TP.HCM",
  configuration: { "floors" => 20, "amenities" => [ "pool", "gym" ] }
)
condo2 = Condo.create!(
  name: "Tòa B - Landmark 81",
  address: "456 Lê Lợi, Quận 1, TP.HCM",
  configuration: { "floors" => 30, "amenities" => [ "tennis court", "bbq area" ] }
)

# Thêm nhiều condos
condo3 = Condo.create!(
  name: "Tòa C - Sunrise City",
  address: "789 Trần Hưng Đạo, Quận 5, TP.HCM",
  configuration: { "floors" => 15, "amenities" => [ "playground", "yoga room" ] }
)
condo4 = Condo.create!(
  name: "Tòa D - Masteri",
  address: "1010 Võ Văn Kiệt, Quận 6, TP.HCM",
  configuration: { "floors" => 25, "amenities" => [ "cinema", "rooftop garden" ] }
)

# Tạo users
puts "Tạo users..."
super_admin = User.create!(
  email: "superadmin@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "super_admin",
  first_name: "Quản trị",
  last_name: "Hệ thống",
  phone_number: "0901234567"
)
operation_admin = User.create!(
  email: "operation@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "operation_admin",
  first_name: "Vận hành",
  last_name: "Tòa nhà",
  phone_number: "0901234568",
  condo_id: condo1.id
)
house_owner = User.create!(
  email: "owner@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "house_owner",
  first_name: "Chủ",
  last_name: "Nhà",
  phone_number: "0901234569",
  condo_id: condo1.id
)
house_member = User.create!(
  email: "member@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "house_member",
  first_name: "Thành viên",
  last_name: "Gia đình",
  phone_number: "0901234570",
  condo_id: condo2.id
)

# Thêm nhiều users
10.times do |i|
  User.create!(
    email: "user#{i+1}@example.com",
    password: "password123",
    password_confirmation: "password123",
    role: [ "house_owner", "house_member", "operation_admin" ].sample,
    first_name: "User#{i+1}",
    last_name: "Test",
    phone_number: "09012345#{format('%02d', i+11)}",
    condo_id: [ condo1.id, condo2.id, condo3.id, condo4.id ].sample
  )
end

# Tạo units
puts "Tạo units..."
unit1 = Unit.create!(
  unit_number: "A-101",
  condo_id: condo1.id,
  house_owner_id: house_owner.id,
  floor: 1,
  size: 75.5
)
unit2 = Unit.create!(
  unit_number: "B-202",
  condo_id: condo2.id,
  house_owner_id: house_owner.id,
  floor: 2,
  size: 90.0
)

# Thêm nhiều units
unit3 = Unit.create!(
  unit_number: "C-303",
  condo_id: condo3.id,
  house_owner_id: User.where(role: "house_owner").last.id,
  floor: 3,
  size: 65.0
)
unit4 = Unit.create!(
  unit_number: "D-404",
  condo_id: condo4.id,
  house_owner_id: User.where(role: "house_owner").first.id,
  floor: 4,
  size: 120.0
)

# Tạo unit_members
puts "Tạo unit_members..."

# Thêm nhiều unit_members
User.where(role: "house_member").limit(3).each_with_index do |member, idx|
  UnitMember.create!(
    unit_id: [ unit1.id, unit2.id, unit3.id, unit4.id ][idx],
    user_id: member.id
  )
end

# Tạo facilities
puts "Tạo facilities..."

# Tạo time slots từ 7h-21h (mỗi slot 1 tiếng)
time_slots = []
(7..20).each do |hour|
  time_slots << "#{hour.to_s.rjust(2, '0')}:00-#{(hour + 1).to_s.rjust(2, '0')}:00"
end

# Schedule cho tất cả các ngày trong tuần
availability_schedule = {
  "monday" => time_slots,
  "tuesday" => time_slots,
  "wednesday" => time_slots,
  "thursday" => time_slots,
  "friday" => time_slots,
  "saturday" => time_slots,
  "sunday" => time_slots
}

facility1 = Facility.create!(
  name: "Hồ bơi",
  condo_id: condo1.id,
  description: "Hồ bơi ngoài trời tầng 5",
  availability_schedule: availability_schedule
)
facility2 = Facility.create!(
  name: "Phòng gym",
  condo_id: condo1.id,
  description: "Phòng gym hiện đại tầng 3",
  availability_schedule: availability_schedule
)
facility3 = Facility.create!(
  name: "Sân tennis",
  condo_id: condo2.id,
  description: "Sân tennis ngoài trời",
  availability_schedule: availability_schedule
)

# Thêm nhiều facilities
facility4 = Facility.create!(
  name: "Khu vui chơi trẻ em",
  condo_id: condo3.id,
  description: "Khu vui chơi trong nhà tầng 2",
  availability_schedule: availability_schedule
)
facility5 = Facility.create!(
  name: "Rooftop Garden",
  condo_id: condo4.id,
  description: "Vườn trên mái với view thành phố",
  availability_schedule: availability_schedule
)

# Tạo bookings
puts "Tạo bookings..."
booking1 = Booking.create!(
  user_id: house_member.id,
  facility_id: facility1.id,
  start_time: Time.now + 1.day,
  end_time: Time.now + 1.day + 2.hours,
  purpose: "Bơi thư giãn",
  status: "pending"
)
booking2 = Booking.create!(
  user_id: house_member.id,
  facility_id: facility2.id,
  start_time: Time.now + 2.days,
  end_time: Time.now + 2.days + 1.hour,
  purpose: "Tập gym",
  status: "approved",
  approved_by_id: operation_admin.id
)

# Thêm nhiều bookings
User.limit(3).each_with_index do |u, idx|
  Booking.create!(
    user_id: u.id,
    facility_id: [ facility1.id, facility2.id, facility3.id, facility4.id, facility5.id ].sample,
    start_time: Time.now + (idx+3).days,
    end_time: Time.now + (idx+3).days + (idx+1).hours,
    purpose: "Booking test #{idx+1}",
    status: [ "pending", "approved", "rejected" ].sample,
    approved_by_id: [ operation_admin.id, nil ].sample
  )
end

# Tạo notifications
puts "Tạo notifications..."
Notification.create!(
  user_id: house_member.id,
  message: "Yêu cầu đặt chỗ hồ bơi của bạn đã được gửi.",
  status: "unread",
  category: "booking",
  reference_id: booking1.id,
  reference_type: "Booking"
)
Notification.create!(
  user_id: house_member.id,
  message: "Đặt chỗ phòng gym của bạn đã được phê duyệt.",
  status: "unread",
  category: "booking",
  reference_id: booking2.id,
  reference_type: "Booking"
)
Notification.create!(
  user_id: operation_admin.id,
  message: "Có yêu cầu đặt chỗ mới từ #{house_member.email}.",
  status: "unread",
  category: "admin",
  reference_id: booking1.id,
  reference_type: "Booking"
)

# Thêm nhiều notifications
User.limit(5).each_with_index do |u, idx|
  Notification.create!(
    user_id: u.id,
    message: "Thông báo test #{idx+1} cho user #{u.email}",
    status: [ "unread", "read" ].sample,
    category: [ "booking", "admin", "system" ].sample,
    reference_id: Booking.last.id,
    reference_type: "Booking"
  )
end

puts "Seed hoàn tất! Đã tạo dữ liệu mẫu cho Condo Management System."
