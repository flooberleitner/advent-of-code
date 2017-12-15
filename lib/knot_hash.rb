class String
  def knot_hash(width: 256, rounds: 64)
    input = (0...width).to_a
    postfix_sizes = [17, 31, 73, 47, 23]

    rotation_total = 0 # used to reverse the overall rotation after we are finished
    skip_size = 0
    rounds.times do
      (each_byte.to_a + postfix_sizes).each do |slice_size|
        input.replace(input.shift(slice_size).reverse + input)
        rotation_steps = slice_size + skip_size
        input.rotate!(rotation_steps)
        rotation_total += rotation_steps
        skip_size += 1
      end
    end
    # Last we rotate the hash back to start position
    # slice it up in chunks, XOR the chunks and join
    # the result to a hex string.
    input
      .rotate!(-rotation_total)
      .each_slice(16)
      .map { |s| format('%02x', s.reduce(:^)) }
      .join
  end
end
