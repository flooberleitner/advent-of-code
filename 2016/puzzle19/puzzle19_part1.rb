#!/usr/bin/env ruby

def solve_part1(elves_count)
  puts "solve_part1: elves:#{elves_count}, "
  puts '  Initializing'
  elves = Hash[(0...elves_count).map { |e| [e, 1] }]
  puts '  Solving'
  until elves.size == 1
    keys = elves.keys
    keys.each_with_index do |key, idx|
      next if elves[key].nil? || elves[key].zero?
      if keys[idx] == keys.last
        elves[key] += elves[keys.first]
        elves.delete(keys.first)
      else
        elves[key] += elves[keys[idx + 1]]
        elves.delete(keys[idx + 1])
      end
    end
  end
  puts '  Solved'
  elves.keys.first + 1
end

[
  ['Test 1', 5, 3],
  ['Part 1', 3_012_210, 1_830_117]
].each do |p|
  res = solve_part1(p[1])
  puts "#{p[0]}: #{res}#{res == p[2] ? '' : " (corr:#{p[2]})"}"
end
