#!/usr/bin/env ruby

require_relative '../lib/linked_list'

class ElvesList < LinkedList
  def make_circle
    @tail.next = @head
    @head.prev = @tail
  end

  def shootout_part1
    make_circle
    cur_node = @head
    until @size == 1
      cur_node = cur_node.next.next
      cur_node.prev.delete
    end
  end

  def shootout_part2
    make_circle
    cur_node = @head
    # first move to the node in the middle that will be removed first
    (@size / 2).times do
      cur_node = cur_node.next
    end
    # position cursor after node to be removed
    cur_node = cur_node.next
    cur_node.prev.delete
    # from that first shootout it is always
    # Advance by 1 and delete node previous to cursor.
    # In case of size is even, we move the cursor by one more node before
    # we delete the node previous to cursor
    until @size == 1
      cur_node = cur_node.next
      cur_node = cur_node.next if @size.even?
      cur_node.prev.delete
    end
  end
end

[
  ['Test 1', :shootout_part1, 5, 3],
  ['Part 1', :shootout_part1, 3_012_210, 1_830_117],
  ['Test 2', :shootout_part2, 5, 2],
  ['Part 2', :shootout_part2, 3_012_210, 1_417_887]
].each do |p|
  puts "#{p[0]}:"
  puts '  Setting up elves'
  elves = ElvesList.new
  p[2].times { |idx| elves.add_last(idx + 1) }
  puts '  Starting Shootout'
  elves.send(p[1])
  res = elves.first.data
  puts "  Result: #{res}#{res == p[3] ? '' : " !!! corr:#{p[3]}"}"
end
