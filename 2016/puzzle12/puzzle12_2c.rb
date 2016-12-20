#!/usr/bin/env ruby

# From AOC reddit user https://www.reddit.com/user/yjerem
# Outputs the instructions compiled into a C program
# which runs insanly faster than my Emulator in ruby
C_VALUE = 1

puts '#include <stdio.h>'
puts
puts "int a = 0, b = 0, c = #{C_VALUE}, d = 0;"
puts
puts 'int main() {'

DATA.each.with_index do |line, n|
  puts "line#{n}:"
  if line =~ /^cpy ([abcd]|-?\d+) ([abcd])$/
    puts "  #{Regexp.last_match(2)} = #{Regexp.last_match(1)};"
  elsif line =~ /^cpy (-?\d+) ([abcd])$/
    puts "  #{Regexp.last_match(2)} = #{Regexp.last_match(1)};"
  elsif line =~ /^inc ([abcd])$/
    puts "  #{Regexp.last_match(1)}++;"
  elsif line =~ /^dec ([abcd])$/
    puts "  #{Regexp.last_match(1)}--;"
  elsif line =~ /^jnz ([abcd]|-?\d+) (-?\d+)$/
    puts "  if (#{Regexp.last_match(1)}) goto line#{n + Regexp.last_match(2).to_i};"
  else
    puts "!!! PARSE ERROR: #{line}"
    exit
  end
end

puts
puts '  printf("%d\\n", a);'
puts '  return 0;'
puts '}'
puts

__END__
cpy 1 a
cpy 1 b
cpy 26 d
jnz c 2
jnz 1 5
cpy 7 c
inc d
dec c
jnz c -2
cpy a c
inc a
dec b
jnz b -2
cpy c b
dec d
jnz d -6
cpy 19 c
cpy 14 d
inc a
dec d
jnz d -2
dec c
jnz c -5
