# module for analyzing network graphs
module NetworkAnalysis
  # Basic network node - can connect to other nodes via 
  class Node
    def initialize(name)
      @name = name
      @connected_nodes = {}
    end

    def connect_node(node, edge_value)
      fail "Node '#{node}' already present" if @connected_nodes.key?(node)
      @connected_nodes[node] = edge_value
    end

    def possible_chains(nodes_to_ignore = [])
      nodes_to_check = @connected_nodes.keys - nodes_to_ignore
      return [[self]] if nodes_to_check.empty?

      nodes_to_ignore << self

      # get all remaining chains and insert this node as first element
      chains = nodes_to_check.each_with_object([]) do |node, memo|
        node.possible_chains(nodes_to_ignore).each do |chain|
          memo << chain.insert(0, self)
        end
      end

      nodes_to_ignore.delete(self)
      chains
    end

    def edge_value_for(node)
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
