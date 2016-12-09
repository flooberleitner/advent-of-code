#!/usr/bin/env ruby

if ARGV.size.zero?
  puts 'Please provide path to input file'
  exit 1
end

class Counter
  ZIP_TAG_PAT = /\((?<num_chars>\d+)x(?<reps>\d+)\)/

  def initialize(expand_sub: false, debug: false)
    @expand_sub = expand_sub
    @dbg = debug
  end

  def do_it(input)
    input.map { |i| count_chars(i) }.inject(0, &:+)
  end

  def count_chars(line)
    subject = line.dup
    count = 0

    puts '', 'count_chars' if @dbg

    until subject.empty?
      puts "subject: #{subject}" if @dbg
      # Further actions depend on where the first ZIP_TAG is
      zip_tag_begin = subject.index('(')

      if zip_tag_begin.nil?
        # no more ZIP_TAGs -> add size of subject
        count += subject.size
        subject = ''
      elsif zip_tag_begin > 0
        # we have some chars till the next ZIP_TAG
        # -> count them and continue at the tag
        count += zip_tag_begin
        subject = subject[zip_tag_begin..-1]
      else # subject starts with a ZIP_TAG_PAT
        # get end of ZIP_TAG and remove ZIP_TAG from subject
        zip_tag_end = subject.index(')')
        tag = subject[0..zip_tag_end]
        subject = subject[(zip_tag_end + 1)..-1]

        # now extract pars from ZIP_TAG
        m = tag.match(ZIP_TAG_PAT)
        raise "'#{tag}' did not match ZIP_TAG_PAT" if m.nil?
        num_chars = m[:num_chars].to_i
        reps = m[:reps].to_i

        count += if @expand_sub
                   # expand repeated substring -> count_chars in the substring
                   count_chars(subject[0...num_chars]) * reps
                 else
                   # no further expansion of sub string
                   # -> just count repeated sub string
                   num_chars * reps
                 end
        # continue after the repeated sub string
        subject = subject[num_chars..-1]
      end
    end
    puts "#{line}: #{count}" if @dbg
    count
  end
end

input = open(ARGV[0]).readlines.map(&:strip)

puts "Puzzle09 Step1: #{Counter.new.do_it(input)}"
puts "Puzzle09 Step2: #{Counter.new(expand_sub: true).do_it(input)}"
