#!/usr/bin/env ruby

require_relative '../lib/node_traversal'
require 'digest'

class Node
  def initialize(passcode:, x:, y:, moves: '')
    @passcode = passcode
    @x = x
    @xsize = 4
    @y = y
    @ysize = 4
    @moves = moves
    @dir_moves = {
      'L' => [-1, 0],
      'R' => [1, 0],
      'U' => [0, -1],
      'D' => [0, 1]
    }
  end
  attr_reader :x, :y, :moves

  def neighbors
    directions.chars.map do |dir|
      Node.new(
        passcode: @passcode,
        x: @x + @dir_moves[dir][0],
        y: @y + @dir_moves[dir][1],
        moves: @moves + dir
      )
    end
  end

  def eql?(other)
    @x == other.x && @y == other.y
  end

  def ==(other)
    eql?(other)
  end

  def directions
    # meaning of first 4 character positions in the hash
    # -> zip them with if there is an available door
    rpc = Digest::MD5.hexdigest(@passcode + @moves)[0..3]
    doors = 'UDLR'.chars.select.with_index { |_c, i| rpc[i] =~ /[b-f]/ }
    doors.delete('L') if @x <= 0
    doors.delete('R') if @x >= (@xsize - 1)
    doors.delete('U') if @y <= 0
    doors.delete('D') if @y >= (@ysize - 1)
    doors.join
  end
end

def solve(start:, target:)
  shortest = nil
  longest = nil
  node_searcher = NodeTraversal.new do |ns|
    ns.traverse_all
    ns.on_next_nodes(&:neighbors)
    ns.on_check_node do |n|
      if n == target
        shortest = n unless shortest
        longest = n
        :next
      end
    end
  end
  node_searcher.run(start)
  [shortest, longest]
end

[
  ['Test 1', 'ihgpwlah', 'DDRRRD', 370],
  ['Test 2', 'kglvqrro', 'DDUDRLRRUDRD', 492],
  ['Test 3', 'ulqzkmiv', 'DRURDRUDDLLDLUURRDULRLDUUDDDRR', 830],
  ['Puzzle 17', 'veumntbg', 'DDRRULRDRD', 536]
].each do |d|
  puts "#{d[0]}:"
  res = solve(
    start: Node.new(passcode: d[1], x: 0, y: 0),
    target: Node.new(passcode: d[1], x: 3, y: 3)
  )
  p1 = res.first.moves
  puts " Shortest: #{p1}#{p1 == d[2] ? '' : " !!! corr: #{d[2]}"}"
  p2 = res[1].moves.size
  puts "  Longest: #{p2}#{p2 == d[3] ? '' : " !!! corr: #{d[3]}"}"
end
