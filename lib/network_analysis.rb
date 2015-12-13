# module for analyzing network graphs
module NetworkAnalysis
  # Basic network node - can connect to other nodes via
  class Node
    def initialize(name)
      @name = name
      @connected_nodes = {}
    end

    # connect a node via an edge
    # edge can be a custom structure
    def connect_node(node, edge)
      fail "Node '#{node}' already present" if @connected_nodes.key?(node)
      @connected_nodes[node] = edge
    end

    def paths(nodes_to_ignore = [])
      nodes_to_check = @connected_nodes.keys - nodes_to_ignore
      return [[self]] if nodes_to_check.empty?

      nodes_to_ignore << self

      # get all remaining paths and insert this node as first element
      paths = nodes_to_check.each_with_object([]) do |node, memo|
        node.paths(nodes_to_ignore).each do |path|
          memo << path.insert(0, self)
        end
      end

      nodes_to_ignore.delete(self)
      paths
    end

    def edge_to(node)
      @connected_nodes[node]
    end

    def inspect
      to_i
    end

    def to_i
      @name
    end
  end
end
