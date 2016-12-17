#!/usr/bin/env ruby

def disk_fill(initial, disk_size)
  out = initial
  until out.size > disk_size
    out << '0'
    out << out[0..-2].reverse.tr('10', '01')
  end

  out[0...disk_size]
end

# TODO: memory optimized version
# - calculate how many checksum steps would be needed from the final disksize
# - trickle down the checksum till final stage
def checksum(content)
  out = ''
  (0...content.size).step(2) do |idx|
    sub = content[idx..(idx + 1)]
    case sub
    when '00' then out << '1'
    when '11' then out << '1'
    when '01' then out << '0'
    when '10' then out << '0'
    else
      raise "Unknown pattern '#{sub}'@#{idx}"
    end
  end

  out = out
  if out.size.even?
    checksum(out)
  else
    out
  end
end

puts "Test Checksum: #{checksum('110010110100')} (corr: 100)"
puts "Puzzle16 Part 1: #{checksum(disk_fill('11110010111001001', 272))} "\
     "(corr: 01110011101111011)"

fill_part2 = disk_fill('11110010111001001', 35_651_584)
puts "calculating checksum - takes some time and RAM"
puts "Puzzle16 Part 2: #{checksum(fill_part2)} "\
     "(corr: 11001111011000111)"
