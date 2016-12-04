#!/usr/bin/env ruby

if ARGV.size.zero?
  puts 'Please provide path to input file'
  exit 1
end

def rotate(char, count)
  return ' ' if char == '-'
  new_char_ord = char.ord + (count % 26)
  new_char_ord -= 26 if new_char_ord > 'z'.ord
  new_char_ord.chr
end

pattern = /^(?<room>[a-z-]+)-(?<sector_id>\d{3,})\[(?<checksum>[a-z]{5})\]$/
sec_id_sum = 0
np_storage_sec_id = 0
open(ARGV[0]) do |file|
  file.readlines.each do |line|
    line.match(pattern) do |match|
      checksum = match[:room]
                 .tr('-', '') # dashes not need
                 .split('') # we want to iterate over each single char
                 .each_with_object(Hash.new(0)) do |char, memo|
                   memo[char] += 1 # each char is the key to it's count
                 end # next sort the hash by count values
                 .sort_by(&:last) # -> [['a' => 3], ['c' => 5], ...]
                 .reverse # but we want the most used chars first
                 .each_with_object(Hash.new('')) do |map, memo|
                   memo[map[1]] += map[0]
                 end # for each count we have the chars in decending order but
                 .values # entries with multiple chars need to be sorted
                 .map { |chars| chars.split('').sort.join } # alphabetically and
                 .join[0..4] # joined together for the checksum (first 5 chars)
      if match[:checksum] == checksum
        sec_id = match[:sector_id].to_i
        sec_id_sum += sec_id
        room_name = match[:room].split('').map { |c| rotate(c, sec_id) }.join
        np_storage_sec_id = sec_id if room_name == 'northpole object storage'
      end
    end
  end
end

puts "Puzzle04 Step1: #{sec_id_sum}"
puts "Puzzle04 Step2: #{np_storage_sec_id}"
