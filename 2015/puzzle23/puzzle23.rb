#!/usr/bin/env ruby


sc = <<~SRC
/* AOC Puzzle 2015/23 transpiled */

#include <stdio.h>

long calc_b(long a, long b);

int main(void) {
  printf("Part 1: %ld (corr: 170)\\n", calc_b(0, 0));
  printf("Part 2: %ld (corr: 247)\\n", calc_b(1, 0));
}

long calc_b(long a, long b) {
SRC

idx = 0
DATA.each do |cmd|
  sc << "  line#{idx}:\n"

  sc << case cmd
  when /^hlf (?<reg>[ab]{1})$/
    "    #{Regexp.last_match(:reg)} /= 2;\n"
  when /^tpl (?<reg>[ab]{1})$/
    "    #{Regexp.last_match(:reg)} *= 3;\n"
  when /^inc (?<reg>[ab]{1})$/
    "    #{Regexp.last_match(:reg)}++;\n"
  when /^jmp (?<offset>[+-]?\d+)$/
    "    goto line#{idx + Regexp.last_match(:offset).to_i};\n"
  when /^jie (?<reg>[ab]{1}), (?<offset>[+-]?\d+)$/
    "    if ((#{Regexp.last_match(:reg)} & 0x01) == 0) goto line#{idx + Regexp.last_match(:offset).to_i};\n"
  when /^jio (?<reg>[ab]{1}), (?<offset>[+-]?\d+)$/
    "    if (#{Regexp.last_match(:reg)} == 1) goto line#{idx + Regexp.last_match(:offset).to_i};\n"
  else
    raise "Unknown command: #{cmd}"
  end
  idx += 1
end

sc << <<~SRC
  line#{idx}:

  return b;
}
SRC

puts sc

__END__
jio a, +16
inc a
inc a
tpl a
tpl a
tpl a
inc a
inc a
tpl a
inc a
inc a
tpl a
tpl a
tpl a
inc a
jmp +23
tpl a
inc a
inc a
tpl a
inc a
inc a
tpl a
tpl a
inc a
inc a
tpl a
inc a
tpl a
inc a
tpl a
inc a
inc a
tpl a
inc a
tpl a
tpl a
inc a
jio a, +8
inc b
jie a, +4
tpl a
inc a
jmp +2
hlf a
jmp -7
