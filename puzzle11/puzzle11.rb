#!/usr/bin/env ruby

class String
  def my_increment!(forbidden = [])
    return '' if size == 0

    if size > 1
      (0...size).each do |index|
        cur_chr = self[size - 1 - index].downcase
        # check for forbidden chars
        new_chr = cur_chr.my_increment(forbidden)
        self[size - 1 - index] = new_chr
        # if new_chr is an 'a' we had a wrap-around and continue with next char
        next if new_chr == 'a'
        break
      end
    else
      increment = proc { self[0] = self == 'z' ? 'a' : (ord + 1).chr }
      increment.call
      # in case we hit a frobidden char, increment till char is allowed
      increment.call while forbidden.include?(self)
    end
    self
  end

  def my_increment(forbidden = [])
    new_str = clone
    new_str.my_increment!(forbidden)
  end

  def doubles?
    scan(/(([\w])\2)/).flatten.reject { |obj| obj.size != 2 }.uniq.size > 1
  end

  def straight?(length)
    return false if size < length

    (0..(size - length)).each do |index|
      first = self[index]
      got_it = (1...length).reduce(true) do |memo, off|
        memo && (self[index + off] == (first.ord + off).chr)
      end
      return true if got_it
    end
    false
  end

  def next_password!
    cnt = 0
    loop do
      cnt += 1
      print '.' if cnt % 10_000 == 0
      my_increment!(%w(i o l))
      next if /[iol]+/.match(self)
      break if doubles? && straight?(3)
    end
    self
  end

  def next_password
    str = clone
    str.next_password!
  end
end
inputs = {
  test1: 'abcdefgh',
  test2: 'ghijklmn',
  part1: 'hepxcrrq'
}
what_to_do = :part1

password = inputs[what_to_do]
print "Searching next password after '#{password}'..."
new_password = password.next_password
puts ''
puts "Puzzle11: Pt01: new pass is '#{new_password}'"

print "Searching next password after '#{new_password}'..."
new_password = new_password.next_password
puts ''
puts "Puzzle11: Pt02: new pass is '#{new_password}'"
