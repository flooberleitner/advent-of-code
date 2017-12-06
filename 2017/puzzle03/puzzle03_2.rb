#!/usr/bin/env ruby

require_relative '../../lib/board'

# Declare the number of the AOC17 puzzle
PUZZLE = 3

# Declare all runs to be done for this puzzle
RUNS = {
  test1: {
    input: 1,
    target: 1
  },
  test2: {
    input: 2,
    target: 3
  },
  test3: {
    input: 4,
    target: 4
  },
  test4: {
    input: 5,
    target: 5
  },
  test5: {
    input: 10,
    target: 6
  },
  test6: {
    input: 11,
    target: 7
  },
  test7: {
    input: 23,
    target: 8
  },
  test8: {
    input: 25,
    target: 9
  },
  test9: {
    input: 26,
    target: 10
  },
  test10: {
    input: 27,
    target: 11
  },
  test11: {
    input: 40,
    target: 11
  },
  puzzle02: {
    input: 289_326,
    target: 0
  }
}.freeze

# 147  142  133  122   59
# 304    5    4    2   57
# 330   10    1    1   54
# 351   11   23   25   26
# 362  747  806--->   ...

def main
  # Make each run
  RUNS.each do |name, data|
    # skip run?
    if data[:skip]
      puts "Skipped '#{name}'"
      next
    end

    # Process data
    target = data[:input]
    board = Board.new
    side_length = 1
    x = y = 0
    current_value = 1
    board[x, y] = current_value

    while current_value <= target
      # side of new ring is 2 more than previous
      side_length += 2
      # move cursor to first corner of new ring
      x += 1
      y -= 1
      # add elements for each side of the whole ring
      [[0, 1], [-1, 0], [0, -1], [1, 0]].each do |mod|
        (side_length - 1).times do
          x += mod[0]
          y += mod[1]
          current_value = board.neighbors(x, y).sum
          board[x, y] = current_value
          break if current_value > target
        end
        break if current_value > target
      end
    end

    # Print result
    res = board.cell_count
    success_msg = res == data[:target] ? 'succeeded' : 'failed'
    puts "AOC17-#{PUZZLE}/#{name} #{success_msg}: #{res}, #{current_value} (Target: #{data[:target]})"
  end
end

main
