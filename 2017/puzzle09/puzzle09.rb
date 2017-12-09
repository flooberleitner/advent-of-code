#!/usr/bin/env ruby

class String
  def remove_pattern(pattern)
    cleaned = clone
    cleaned.gsub!(pattern, '') while cleaned =~ pattern
    cleaned
  end
end

def basic_clean(input)
  input.remove_pattern(/!!/).remove_pattern(/!.{1}/)
end

def full_clean(input)
  basic_clean(input).remove_pattern(/<[<\w'",{}]*>/)
end

def count_garbage(input)
  with_garbage = basic_clean(input)
  matches = with_garbage.scan(/<[<\w'",{}]*>/)
  if matches.empty?
    0
  else
    matches.map { |m| m.size - 2 }.sum
  end
end

def group_value(input)
  depth = 0
  val = 0
  full_clean(input).chars.each do |c|
    if c == '{'
      depth += 1
      val += depth
    elsif c == '}'
      depth -= 1
    elsif c == ','
      # do nothing
    else
      raise "Unhandled char '#{c}'"
    end
  end
  val
end

# Declare the number of the AOC17 puzzle
PUZZLE = 9

# Declare all runs to be done for this puzzle
{
  test1: {
    input: '{}',
    target1: 1,
    target2: 0
  },
  test2: {
    input: '{{{}}}',
    target1: 6,
    target2: 0
  },
  test3: {
    input: '{{},{}}',
    target1: 5,
    target2: 0
  },
  test4: {
    input: '{{{},{},{{}}}}',
    target1: 16,
    target2: 0
  },
  test5: {
    input: '{<a>,<a>,<a>,<a>}',
    target1: 1,
    target2: 4
  },
  test6: {
    input: '{{<ab>},{<ab>},{<ab>},{<ab>}}',
    target1: 9,
    target2: 8
  },
  test7: {
    input: '{{<!!>},{<!!>},{<!!>},{<!!>}}',
    target1: 9,
    target2: 0
  },
  test8: {
    input: '{{<a!>},{<a!>},{<a!>},{<ab>}}',
    target1: 3,
    target2: 17
  },
  puzzle: {
    input: 'input.txt',
    target1: 23_588,
    target2: 10_045
  }
}.each do |run_name, run_pars|
  # skip run?
  if run_pars[:skip]
    puts "Skipped '#{run_name}'"
    next
  end

  # open input data and process it
  input = if File.exist?(run_pars[:input])
            open(run_pars[:input]) do |file|
              # Read all input lines and sanitize
              file.readlines.map(&:strip).first
            end
          else
            # use input parameter directly
            run_pars[:input]
          end

  # Process data
  res1 = group_value(input)
  res2 = count_garbage(input)

  # Print result
  success_msg1 = res1 == run_pars[:target1] ? 'succeeded' : 'failed'
  success_msg2 = res2 == run_pars[:target2] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name}1 #{success_msg1}: #{res1} (Target: #{run_pars[:target1]})"
  puts "AOC17-#{PUZZLE}/#{run_name}2 #{success_msg2}: #{res2} (Target: #{run_pars[:target2]})"
  puts '=' * 25
end
