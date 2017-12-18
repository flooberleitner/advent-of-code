#!/usr/bin/env ruby

# Declare the number of the AOC17 puzzle
PUZZLE = 13

class Layer
  def initialize(depth: 0, range: nil)
    @range = range
    @depth = depth
    for_cycle(tics: 0)
  end
  attr_reader :range, :depth, :scanner_pos

  def for_cycle(tics: 0)
    if tics.zero? || @range.nil?
      @scanner_pos = 0
      @move_up = true
    else
      remainder = tics % (@range - 1)
      cycles = tics / (@range - 1)
      @scanner_pos = if cycles.even?
                       remainder
                     else
                       @scanner_pos = @range - 1 - remainder
                     end
    end
  end

  def hit?
    return false if @range.nil?
    return false if @scanner_pos > 0
    true
  end

  def hit_value
    return 0 unless @range
    @depth * @range
  end
end

class Firewall
  def initialize(config_data:)
    @config_data = config_data
    @layers = Hash.new { |h, k| h[k] = Layer.new }

    @config_data.each do |layer_cfg|
      m = layer_cfg.match(/(?<depth>\d+): (?<range>\d+)/)
      raise "Layer cfg '#{layer_cfg}' does not match" unless m
      d = m[:depth].to_i
      r = m[:range].to_i
      @layers[d] = Layer.new(depth: d, range: r)
    end

    @layer_count = @layers.keys.sort.last
  end

  def send_packet(delay: 0, exit_on_hit: false)
    hit = false
    severity = 0
    (0..@layer_count).each do |packet_pos|
      layer = @layers[packet_pos]
      layer.for_cycle(tics: delay + packet_pos)
      hit ||= layer.hit?
      severity += layer.hit_value if layer.hit?
      break if exit_on_hit && hit
    end
    [hit, severity]
  end

  def delay_without_detection
    delay = 0
    loop do
      hit, _severity = send_packet(delay: delay, exit_on_hit: true)
      return delay unless hit
      delay += 1
    end
  end
end

# Declare all runs to be done for this puzzle
{
  test: {
    input: 'input_test.txt',
    target1: 24,
    target2: 10
  },
  puzzle: {
    skip: false,
    input: 'input.txt',
    target1: 648,
    target2: 3_933_124
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
              file.readlines.map(&:strip)
            end
          else
            # use input parameter directly
            run_pars[:input]
          end

  # Process data
  firewall = Firewall.new(config_data: input)

  _, res1 = firewall.send_packet
  success_msg1 = res1 == run_pars[:target1] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name}/1 #{success_msg1}: #{res1} (Target: #{run_pars[:target1]})"

  res2 = firewall.delay_without_detection
  success_msg2 = res2 == run_pars[:target2] ? 'succeeded' : 'failed'
  puts "AOC17-#{PUZZLE}/#{run_name}/2 #{success_msg2}: #{res2} (Target: #{run_pars[:target2]})"

  puts '=' * 50
end
