# db/seeds.rb
require 'securerandom'

# Delete all existing data to avoid duplication
puts "Deleting old data..."
User.delete_all
Condo.delete_all
Unit.delete_all
UnitMember.delete_all
Facility.delete_all
Booking.delete_all
Notification.delete_all

# Reset sequence (if needed, but not necessary with uuid)
ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end

# Create condos
puts "Creating condos..."
condo1 = Condo.create!(
  name: "Building A - Vinhomes",
  address: "123 Nguyen Hue, District 1, HCMC",
  configuration: { "floors" => 20, "amenities" => [ "pool", "gym" ] }
)
condo2 = Condo.create!(
  name: "Building B - Landmark 81",
  address: "456 Le Loi, District 1, HCMC",
  configuration: { "floors" => 30, "amenities" => [ "tennis court", "bbq area" ] }
)

# Add more condos
condo3 = Condo.create!(
  name: "Building C - Sunrise City",
  address: "789 Tran Hung Dao, District 5, HCMC",
  configuration: { "floors" => 15, "amenities" => [ "playground", "yoga room" ] }
)
condo4 = Condo.create!(
  name: "Building D - Masteri",
  address: "1010 Vo Van Kiet, District 6, HCMC",
  configuration: { "floors" => 25, "amenities" => [ "cinema", "rooftop garden" ] }
)

# Create users
puts "Creating users..."
super_admin = User.create!(
  email: "superadmin@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "super_admin",
  first_name: "System",
  last_name: "Administrator",
  phone_number: "0901234567"
)
operation_admin = User.create!(
  email: "operation@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "operation_admin",
  first_name: "Operation",
  last_name: "Admin",
  phone_number: "0901234568",
  condo_id: condo1.id
)
house_owner = User.create!(
  email: "owner@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "house_owner",
  first_name: "House",
  last_name: "Owner",
  phone_number: "0901234569",
  condo_id: condo1.id
)
house_member = User.create!(
  email: "member@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "house_member",
  first_name: "Family",
  last_name: "Member",
  phone_number: "0901234570",
  condo_id: condo2.id
)

# Add more users
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

# Create units
puts "Creating units..."
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

# Add more units
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

# Create unit_members
puts "Creating unit_members..."

# Add more unit_members
User.where(role: "house_member").limit(3).each_with_index do |member, idx|
  UnitMember.create!(
    unit_id: [ unit1.id, unit2.id, unit3.id, unit4.id ][idx],
    user_id: member.id
  )
end

# Create facilities
puts "Creating facilities..."

# Create time slots from 7am-9pm (each slot 1 hour)
time_slots = []
(7..20).each do |hour|
  time_slots << "#{hour.to_s.rjust(2, '0')}:00-#{(hour + 1).to_s.rjust(2, '0')}:00"
end

# Schedule for all days of the week
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
  name: "Swimming Pool",
  condo_id: condo1.id,
  description: "Outdoor swimming pool on 5th floor",
  availability_schedule: availability_schedule
)
facility2 = Facility.create!(
  name: "Gym Room",
  condo_id: condo1.id,
  description: "Modern gym on 3rd floor",
  availability_schedule: availability_schedule
)
facility3 = Facility.create!(
  name: "Tennis Court",
  condo_id: condo2.id,
  description: "Outdoor tennis court",
  availability_schedule: availability_schedule
)

# Add more facilities
facility4 = Facility.create!(
  name: "Children's Playground",
  condo_id: condo3.id,
  description: "Indoor playground on 2nd floor",
  availability_schedule: availability_schedule
)
facility5 = Facility.create!(
  name: "Rooftop Garden",
  condo_id: condo4.id,
  description: "Rooftop garden with city view",
  availability_schedule: availability_schedule
)

# Create bookings
puts "Creating bookings..."
booking1 = Booking.create!(
  user_id: house_member.id,
  facility_id: facility1.id,
  start_time: Time.now + 1.day,
  end_time: Time.now + 1.day + 2.hours,
  purpose: "Relaxing swim",
  status: "pending"
)
booking2 = Booking.create!(
  user_id: house_member.id,
  facility_id: facility2.id,
  start_time: Time.now + 2.days,
  end_time: Time.now + 2.days + 1.hour,
  purpose: "Gym workout",
  status: "approved",
  approved_by_id: operation_admin.id
)

# Add more bookings
User.limit(3).each_with_index do |u, idx|
  Booking.create!(
    user_id: u.id,
    facility_id: [ facility1.id, facility2.id, facility3.id, facility4.id, facility5.id ].sample,
    start_time: Time.now + (idx+3).days,
    end_time: Time.now + (idx+3).days + (idx+1).hours,
    purpose: "Test booking #{idx+1}",
    status: [ "pending", "approved", "rejected" ].sample,
    approved_by_id: [ operation_admin.id, nil ].sample
  )
end

# Create notifications
puts "Creating notifications..."
Notification.create!(
  user_id: house_member.id,
  message: "Your swimming pool booking request has been sent.",
  status: "unread",
  category: "booking",
  reference_id: booking1.id,
  reference_type: "Booking"
)
Notification.create!(
  user_id: house_member.id,
  message: "Your gym booking has been approved.",
  status: "unread",
  category: "booking",
  reference_id: booking2.id,
  reference_type: "Booking"
)
Notification.create!(
  user_id: operation_admin.id,
  message: "New booking request from #{house_member.email}.",
  status: "unread",
  category: "admin",
  reference_id: booking1.id,
  reference_type: "Booking"
)

# Add more notifications
User.limit(5).each_with_index do |u, idx|
  Notification.create!(
    user_id: u.id,
    message: "Test notification #{idx+1} for user #{u.email}",
    status: [ "unread", "read" ].sample,
    category: [ "booking", "admin", "system" ].sample,
    reference_id: Booking.last.id,
    reference_type: "Booking"
  )
end

puts "Seeding complete! Sample data created for Condo Management System."
