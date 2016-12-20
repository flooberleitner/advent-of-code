#!/usr/bin/env ruby

if ARGV.size.zero?
  puts 'Please provide path to input file'
  exit 1
end

class BlackList
  def initialize(input, max = 4_294_967_295)
    @max = max
    @ranges = input.map do |l|
      l.match(/^(?<from>\d+)-(?<to>\d+)$/) { |m| next [m[:from].to_i, m[:to].to_i] }
    end.sort
    raise 'range with from > to' unless @ranges.all? { |r| r.first < r.last }
    raise 'from/to too high' if @ranges.any? { |r| r.first > @max || r.last > @max }
    @ranges = condense(@ranges)
  end

  def first_free
    @ranges[0][1] + 1
  end

  def allowed_count
    # total number of elements is value of @max + 1
    # from there we substract the number of elements in each range
    @ranges.inject(@max + 1) { |acc, elem| acc - (elem[1] - elem[0] + 1) }
  end

  private def condense(ranges)
    condensed = []
    last_from = nil
    last_to = nil
    ranges.size.times do |idx|
      range = ranges[idx]
      if idx == ranges.size - 1
        # last range -> finish up the last condensed range
        # TO for condensed range is the bigger one of last_to|current range
        condensed << [last_from, [last_to, range[1]].max]
      elsif last_from.nil?
        last_from, last_to = range
      elsif last_to < range[0] - 1
        # Distance from last_to to next FROM is at least 1
        # -> we have a gap so a new condensed range can be added
        condensed << [last_from, last_to]
        last_from, last_to = range
      elsif last_to < range[1]
        # new_range with last_to would also span current range
        # -> continue search with current TO
        last_to = range[1]
      end
      # last_to is bigger than current TO or same as current from
      # -> check next range
    end
    condensed
  end
end

input = open(ARGV[0]).readlines.map(&:strip)

[
  ['Test', BlackList.new(['5-8', '0-2', '4-7'], 9), 3, 2],
  ['Test 2', BlackList.new(['5-8', '0-2', '4-7', '5-6',
                            '5-7', '6-7', '7-8', '4-8', '4-9'], 9), 3, 1],
  ['Puzzle20', BlackList.new(input), 31_053_880, 117]
].each do |p|
  ff = p[1].first_free
  ac = p[1].allowed_count
  puts "#{p[0]} Part 1: #{ff}#{ff == p[2] ? '' : " !!! corr:#{p[2]}"} "
  puts "#{p[0]} Part 2: #{ac}#{ac == p[3] ? '' : " !!! corr:#{p[3]}"} "
end
