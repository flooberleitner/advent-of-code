#!/usr/bin/env ruby

ROW = 3010
COL = 3019
VAL_1_1 = 20_151_125

def col1_in_row(row)
  (1..row).inject(1) { |acc, elem| acc + elem - 1 }
end

def calc_el_idx(row, col)
  col1_in_row(row + col - 1) + col - 1
end

def calc_pos(row, col)
  idx = calc_el_idx(row, col)
  (2..idx).inject(VAL_1_1) { |acc, _elem| (acc * 252_533) % 33_554_393 }
end

res = calc_pos(ROW, COL)
puts "Part 1: #{res}#{res == 8_997_277 ? '' : ' !!! corr: 8997277'}"
