#!/usr/bin/env ruby

class Processor
  DBG = false
  def initialize(instructions)
    @instructions = parse_instructions(instructions)
    # @instructions.each { |i| puts i.inspect }
  end

  def process(string, undo = false)
    insts = undo ? @instructions.reverse : @instructions
    insts.each do |i|
      puts "\n#{i[0].to_s.rjust(11)}#{i[1..-1].inspect.ljust(11)}" if DBG
      out = send(i[0], string, *i[1..-1], undo)
      puts "#{string} -> #{out}" if DBG
      string = out
    end
    string
  end

  def swap_pos(string, x, y, undo)
    puts "  swap_pos(#{string}, #{x}, #{y}, #{undo})" if DBG
    str = string.dup
    tmp = str[x]
    str[x] = str[y]
    str[y] = tmp
    str
  end

  def swap_letter(string, char1, char2, undo)
    puts "  swap_letter(#{string}, #{char1}, #{char2}, #{undo})" if DBG
    swap_pos(string, string.index(char1), string.index(char2), undo)
  end

  def rotate_dir(string, dir, dist, undo = false)
    puts "  rotate_dir(#{string}, #{dir}, #{dist}, #{undo})" if DBG
    swap = { right: :left, left: :right }
    dir = swap[dir] if undo
    string.chars.rotate!(dir == :left ? dist : -dist).join
  end

  def rotate_pos(string, letter, undo)
    puts "  rotate_pos(#{string}, #{letter}, #{undo})" if DBG
    rotate_dir(string, :right, get_distance(string, letter, undo), undo)
  end

  def get_distance(string, letter, undo)
    dist = ->(idx) { 1 + idx + (idx >= 4 ? 1 : 0) }
    letter_idx = string.index(letter)
    return dist.call(letter_idx) unless undo
    # for undo we see which normal operation leads to the current position of the character
    string.size.times do |i|
      d = dist.call(i)
      new_pos = (i + d) % string.size
      return d if new_pos == letter_idx
    end
    raise "No distance found for (#{string}, #{letter}, #{undo})"
  end

  def reverse(string, from, to, undo)
    puts "  undo(#{string}, #{from}, #{to}, #{undo})" if DBG
    string[0...from] + string[from..to].reverse + string[(to + 1)..-1]
  end

  def move(string, from, to, undo)
    puts "  move(#{string}, #{from}, #{to}, #{undo})" if DBG
    p = [from, to]
    p.reverse! if undo
    from = p[0]
    to = p[1]
    str = string.chars
    rm = str.delete_at(from)
    str.insert(to, rm).join
  end

  private def parse_instructions(instructions)
    instructions.map do |instruction|
      case instruction
      when /^swap position (?<x>\d+) with position (?<y>\d+)$/
        [:swap_pos, Regexp.last_match(:x).to_i, Regexp.last_match(:y).to_i]
      when /^swap letter (?<c1>\w{1}) with letter (?<c2>\w{1})$/
        [:swap_letter, Regexp.last_match(:c1), Regexp.last_match(:c2)]
      when /^rotate (?<dir>left|right) (?<dist>\d+) steps?$/
        [:rotate_dir, Regexp.last_match(:dir).to_sym, Regexp.last_match(:dist).to_i]
      when /^rotate based on position of letter (?<ltr>\w+)$/
        [:rotate_pos, Regexp.last_match(:ltr)]
      when /^reverse positions (?<from>\d+) through (?<to>\d+)$/
        [:reverse, Regexp.last_match(:from).to_i, Regexp.last_match(:to).to_i]
      when /^move position (?<from>\d+) to position (?<to>\d+)$/
        [:move, Regexp.last_match(:from).to_i, Regexp.last_match(:to).to_i]
      else
        raise "Unknonw instruction '#{instruction}'"
      end
    end
  end
end

[
  ['Test 1', 'puzzle21_input_test.txt', false, 'abcde', 'decab'],
  ['Part 1', 'puzzle21_input.txt', false, 'abcdefgh', 'dbfgaehc'],
  ['Part 2', 'puzzle21_input.txt', true, 'fbgdceah', 'aghfcdeb']
].each do |p|
  input = open(p[1]).readlines.map(&:strip)
  processor = Processor.new(input)
  res = processor.process(p[3], p[2])
  puts "#{p[0]}: #{res}#{res == p[4] ? '' : " !!! corr: #{p[4]}"}"
end
