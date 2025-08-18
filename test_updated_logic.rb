#!/usr/bin/env ruby

puts "=== Testing Updated User Unit Logic ==="

# Test creating a new user with unit assignment
puts "\n=== Testing Create User with Unit ==="
unit_a101 = Unit.find_by(unit_number: "A-101")
puts "Unit A-101 condo_id: #{unit_a101.condo_id}"

new_user = User.new(
  first_name: "Test",
  last_name: "User",
  email: "test_user_#{Time.now.to_i}@example.com",
  role: "house_member",
  password: "password123",
  password_confirmation: "password123"
)

if new_user.save
  puts "New user created: #{new_user.email}"

  # Test unit assignment (simulating controller logic)
  new_user.update!(condo_id: unit_a101.condo_id)
  new_user.unit_members.create!(unit: unit_a101)

  puts "User after unit assignment:"
  puts new_user.debug_unit_relationships.inspect

  puts "\nUnit A-101 members now:"
  unit_a101.reload.members.each do |member|
    puts "- #{member.email}"
  end
else
  puts "Failed to create user: #{new_user.errors.full_messages}"
end

puts "\n=== Testing Unit Member Accessibility ==="
# Test if users in same unit can see each other
unit_members = unit_a101.members
puts "Members in Unit A-101:"
unit_members.each do |member|
  other_members = unit_members.where.not(id: member.id)
  puts "#{member.email} can see #{other_members.count} other members: #{other_members.pluck(:email)}"
end
