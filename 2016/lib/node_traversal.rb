# A simple class providing searching through node type objects
# with breadth/depth first
class NodeTraversal
  def initialize
    @breadth_first = true
    @prng = nil
    @respect_visited = true
    @on_finished_cb = nil
    @on_next_nodes_cb = nil
    @on_check_node_cb = nil
    yield(self) if block_given?
  end

  ##
  # Call it to set BreadthFirst approach
  # DEFAULT
  def breadth_first
    @breadth_first = true
  end

  ##
  # Call it to set DepthFirst approach
  def depth_first
    @breadth_first = false
  end

  ##
  # Next nodes are randomized before they are added to the traversal queue.
  # If +seed+ is given, it is used as seed for the random number generator.
  def randomize(seed = nil)
    @prng = seed ? Random.new(seed) : Random.new
  end

  ##
  # Add the next nodes in the order received via on_next_nodes callback.
  # DEFAULT
  def no_randomize
    @prng = nil
  end

  ##
  # Traverse all nodes, regardless of already visited ones
  def traverse_all
    @respect_visited = false
  end

  ##
  # Do not add nodes to queue if they've already been visited
  # DEFAULT
  def respect_visited
    @respect_visited = true
  end

  ##
  # Passed in block is set as callback upon checking a node for reaching
  # the traversal target.
  # Bloc is expected to have signature |node|.
  # Return :next/:break from block to control the runner loop traversing
  # the nodes.
  # REQUIRED
  def on_check_node(&block)
    @on_check_node_cb = block
  end

  ##
  # Passed in +block+ is set as callback that returns the next nodes for a
  # given node.
  # Must be set before calling #run.
  # Block must be of signature |node|
  # REQUIRED
  def on_next_nodes(&block)
    @on_next_nodes_cb = block
  end

  ##
  # Passed in +block* is set as callback upon finished traversal.
  # Will be handed over the last checked node and an array of all visited
  # nodes.
  # Block expected to have signature |last_checked_node, visited|
  # OPTIONAL
  def on_finished(&block)
    @on_finished_cb = block
  end

  ##
  # Starting traversal beginning with +first_node+
  def run(first_node)
    queued = [first_node]
    visited = []
    last_node_checked = nil

    raise 'No on_check_node callback provided' unless @on_check_node_cb
    raise 'No on_next_nodes callback provided' unless @on_next_nodes_cb

    until queued.empty?
      node = @breadth_first ? queued.delete_at(0) : queued.pop
      last_node_checked = node
      visited.push(node) unless !@respect_visited || visited.include?(node)

      case @on_check_node_cb.call(node)
      when :break then break
      when :next then next
      end

      new_nodes = @on_next_nodes_cb.call(node)
      if @prng && new_nodes.size > 1
        # My answer was too high so I did some random permutations on the
        # order of the neighbours to see if this has influence
        # -> it had!
        # Reason for my algorithm not finding the shortest path was, that
        # I did a DepthFirst (continue with element last added to queue) instead
        # of BreadthFirst (continue with oldest element in queue).
        permutations = new_nodes.permutation.to_a
        new_nodes = permutations[@prng.rand(permutations.size - 1)]
      end

      new_nodes.each do |n|
        queued.push n unless @respect_visited && visited.include?(n)
      end
    end
    @on_finished_cb.call(last_node_checked, visited) if @on_finished_cb
  end
end
