#!/usr/bin/env ruby

require 'digest'

##
# A class for brute forcing passwords according to methods
# provided via test subjects.
# The Brute creates the ciphers and hands them over to each
# subject which then handled the password creation.
class Brute
  CANDIDATE_PAT = /(?=((.)\2\2))/

  def initialize(name:, salt:, key_count:)
    @salt = salt
    @name = name
    @key_count_required = key_count
    @valid_keys = {}
    @key_candidates = {}
    @key_veri_idx_offset = 1000
  end
  attr_reader :name, :valid_keys

  ##
  # Start collecting keys
  def collect
    index = -1
    while @valid_keys.size < @key_count_required
      index += 1

      # Create digest for current index
      digest = Digest::MD5.hexdigest(@salt + index.to_s)
      2016.times { digest = Digest::MD5.hexdigest(digest) }

      # weed out keys that could not be verified till now
      @key_candidates.delete_if do |c_key_index, _v|
        index >= (c_key_index + @key_veri_idx_offset)
      end

      # check if digest validates candidates
      confirmed = @key_candidates.map do |c_key_index, c_digest|
        m = c_digest.match(CANDIDATE_PAT)
        # puts "match: #{m.inspect}" unless m.nil?
        if digest.include?(m[2] * 5)
          next c_key_index
        end
        nil
      end.compact

      confirmed.each do |k_idx|
        puts "== Verified Key #{@valid_keys.size + 1}: #{k_idx}(#{@key_candidates[k_idx]})"
        @valid_keys[k_idx] = @key_candidates.delete(k_idx) if @valid_keys.size < @key_count_required
      end

      # check if digest is a key candidate
      digest.match(CANDIDATE_PAT) do |_|
        # puts "== Add Candidate: #{index}: #{digest}"
        @key_candidates[index] = digest
      end
    end
  end
end

brute = Brute.new(name: 'Part 2', salt: 'cuanljph', key_count: 64)
brute.collect

puts "\nPuzzle 2016/14 results"
puts "  #{brute.name}: #{brute.valid_keys.keys.sort.last} (corr: 20606)"
