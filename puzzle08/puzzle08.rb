#!/usr/bin/env ruby

require 'trollop'

opts = Trollop.options do
  version 'AoC:Puzzle08, (c) Florian Oberleitner (florian.oberleitner@gmail.com)'
  opt :input, 'Path to input data', type: String
end
Trollop.die :input, 'required' unless opts[:input]
Trollop.die :input, 'does not exists' unless File.exist?(opts[:input])

#########################################

strings = File.readlines(opts[:input])

total_raw = strings.map(&:strip).map(&:size).reduce(:+)

total = 0
strings.each do |string|
  # Strip the whitespace, cut leading/trailing double quote, parse each byte.
  # Each_byte needs to be used because ruby partly handles escaped caracters
  # (e.g. double backslash is represented as one).
  skip = 0
  backslash = false
  string.strip[1..-2].each_byte do |byte|
    if skip > 0
      skip -= 1
      next
    end

    if backslash
      backslash = false
      total += 1
      case byte.chr
      when '"'
      when '\\'
      when 'x'
        skip = 2
      else
        fail 'Lonesome backslash'
      end
    elsif byte.chr == '\\'
      backslash = true
    else
      total += 1
    end
  end
end

# Dor part two we need to escape each char in the string.
# String#inspect already does that for us.
total_escaped = strings.map(&:strip).map(&:inspect).map(&:size).reduce(:+)

puts "total_raw:#{total_raw}"
puts "total:#{total}"
puts "total_escaped:#{total_escaped}"
puts ''
puts "Puzzle08 Pt01: #{total_raw - total}"
puts "Puzzle08 Pt02: #{total_escaped - total_raw}"
