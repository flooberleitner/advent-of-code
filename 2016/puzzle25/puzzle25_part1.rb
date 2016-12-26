#!/usr/bin/env ruby

1000.times do |idx|
  start = idx + 4 * 643 # input line 1 - 9
  clock = ''

  a = start
  2.times do
    while a > 0
      # clock tick added is the remainder of a divided by 2
      clock << ((a % 2).zero? ? '0' : '1')
      # we then do the next cycle with a halfed
      a /= 2
    end
    # in total we do this 2 times to see if the clock signal
    # remains correct on wrap around
  end

  # If the clock signal consists just of '01' sequences, then
  # the splitted result should be zero if we use '01' as
  # separator for the split.
  if clock.split('01').empty?
    puts "Part 1: #{idx}"
    break
  end
end
