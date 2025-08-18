#!/usr/bin/env ruby

# Script to test user unit relationship updates
puts "=== Testing User Unit Relationships ==="

# Find users that should be in the same unit
user1 = User.find_by(email: "member@example.com")
user2 = User.find_by(email: "user1@example.com")

puts "\n=== BEFORE UPDATE ==="
puts "User1 (member@example.com):"
puts user1.debug_unit_relationships.inspect
puts "\nUser2 (user1@example.com):"
puts user2.debug_unit_relationships.inspect

# Find a unit they should both belong to
target_unit = Unit.find_by(unit_number: "A-101")
puts "\nTarget Unit A-101:"
puts "ID: #{target_unit.id}"
puts "Condo ID: #{target_unit.condo_id}"
puts "Members: #{target_unit.members.pluck(:email)}"

# Update user1's condo to match the unit's condo
puts "\n=== UPDATING USER1 CONDO ==="
user1.update!(condo_id: target_unit.condo_id)

puts "\n=== AFTER CONDO UPDATE ==="
puts "User1 after condo update:"
puts user1.debug_unit_relationships.inspect

puts "\n=== CHECKING UNIT MEMBERS IN SAME UNIT ==="
unit_a101 = Unit.find_by(unit_number: "A-101")
members_in_a101 = unit_a101.members
puts "Members in Unit A-101:"
members_in_a101.each do |member|
  puts "- #{member.email} (#{member.first_name} #{member.last_name})"
end

puts "\n=== TEST COMPLETE ==="
