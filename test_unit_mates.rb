#!/usr/bin/env ruby

puts "=== Testing unit_mates Method ==="

user1 = User.find_by(email: "user1@example.com")
member = User.find_by(email: "member@example.com")

puts "\n=== User1 unit_mates ==="
user1.unit_mates.each do |mate|
  puts "- #{mate.email} (#{mate.first_name} #{mate.last_name})"
end

puts "\n=== Member unit_mates ==="
member.unit_mates.each do |mate|
  puts "- #{mate.email} (#{mate.first_name} #{mate.last_name})"
end

puts "\n=== Verifying both can see each other ==="
puts "user1 can see member: #{user1.unit_mates.include?(member)}"
puts "member can see user1: #{member.unit_mates.include?(user1)}"
