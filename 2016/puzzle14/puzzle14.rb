#!/usr/bin/env ruby

require_relative '../lib/hash_brute'
require 'digest'

##
# A class for brute forcing passwords according to methods
# provided via test subjects.
# The Brute creates the ciphers and hands them over to each
# subject which then handled the password creation.
class BaseCollector
  include HashBrute::BaseSubject

  CANDIDATE_PAT = /(?=((.)\2\2))/

  def initialize(name:, key_count: 64, max_distance: 1000)
    @name = name
    @key_count_required = key_count
    @key_max_distance = max_distance
    @valid_keys = {}
    @key_candidates = {}
  end

  def take(digest:, index:)
    digest = modify(digest)
    weed_out_candidates(index)
    validate_candidates(digest)
    check_for_new_candidates(digest, index)
  end

  private def weed_out_candidates(current_index)
    @key_candidates.delete_if do |c_key_index, _v|
      current_index >= (c_key_index + @key_max_distance)
    end
  end

  private def validate_candidates(digest)
    confirmed = @key_candidates.map do |c_key_index, c_digest|
      m = c_digest.match(CANDIDATE_PAT)
      # puts "match: #{m.inspect}" unless m.nil?
      if digest.include?(m[2] * 5)
        next c_key_index
      end
      nil
    end.compact

    confirmed.each do |k_idx|
      puts "(#{@name}) Verified Key #{@valid_keys.size + 1}: #{k_idx}(#{@key_candidates[k_idx]})"
      @valid_keys[k_idx] = @key_candidates.delete(k_idx) if @valid_keys.size < @key_count_required
    end
  end

  private def check_for_new_candidates(digest, index)
    digest.match(CANDIDATE_PAT) do |_|
      @key_candidates[index] = digest
    end
  end

  def modify(digest:)
    raise "#{self.class} has no #modify"
  end

  def finished?
    @valid_keys.size >= @key_count_required
  end

  def verbose_result
    "#{@name}: Keys Count=#{@valid_keys.size}, last_index: #{@valid_keys.keys.sort.last}"
  end
end

class Part1Collector < BaseCollector
  def modify(digest)
    digest
  end
end

class Part2Collector < BaseCollector
  def modify(digest)
    out = digest.dup
    2016.times { out = Digest::MD5.hexdigest(out) }
    out
  end
end

brute = HashBrute.new(
  salt: 'cuanljph',
  print_progress_every: 2_000,
  check_finished_every: nil
)
part1 = Part1Collector.new(name: 'Part 1')
brute.add_subject(part1)
part2 = Part2Collector.new(name: 'Part 2')
brute.add_subject(part2)

brute.run

puts "\nPuzzle 2016/14 results"
puts "  #{part1.verbose_result} (cor: 23769)"
puts "  #{part2.verbose_result} (cor: 20606)"
