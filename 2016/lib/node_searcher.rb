# A simple class providing searching through node type objects
# with breadth/depth first
class NodeSearcher
  attr_reader :visited
  def initialize
    @breadth_first = true
    @prng = nil
    @on_finished_cb = nil
    @on_next_nodes_cb = nil
    @on_check_node_cb = nil
    yield(self) if block_given?
  end

  def breadth_first
    @breadth_first = true
  end

  def depth_first
    @breadth_first = false
  end

  def randomize(seed = nil)
    @prng = seed ? Random.new(seed) : Random.new
  end

  def no_randomize
    @prng = nil
  end

  # Block will be passed the current which the next nodes
  # should be returned from as |node|
  def on_next_nodes(&block)
    @on_next_nodes_cb = block
  end

  # Block will receive the last checked node as well as all visited nodes
  # as |last_node_checked, visited|
  def on_finished(&block)
    @on_finished_cb = block
  end

  # Block will receive the current node to be checked as |node|
  # You can return :next/:break to control the runner loop traversing the nodes
  def on_check_node(&block)
    @on_check_node_cb = block
  end

  def run(first_node)
    queued = [first_node]
    visited = []
    last_node_checked = nil

    raise 'No on_check_node callback provided' unless @on_check_node_cb
    raise 'No on_next_nodes callback provided' unless @on_next_nodes_cb

    until queued.empty?
      node = @breadth_first ? queued.delete_at(0) : queued.pop
      last_node_checked = node
      visited.push(node) unless visited.include?(node)

      break_next = @on_check_node_cb.call(node)
      case break_next
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
        permutations[@prng.rand(permutations.size - 1)]
      end

      new_nodes.each do |n|
        queued.push n unless visited.include?(n)
      end
    end
    @on_finished_cb.call(last_node_checked, visited) if @on_finished_cb
  end
end
