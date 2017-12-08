#!/usr/bin/env ruby

require_relative '../../lib/node'

def create_nodes(data)
  nodes = {}

  data.map do |s| # get all node matches
    /(?<name>\w*) \((?<weight>\d*)\)/.match(s)
  end.compact.map do |m| # process matches and create nodes
    nodes[m[:name].to_sym] =
      Node.new(
        name: m[:name],
        weight: m[:weight].to_i
      )
  end

  data.map do |s| # get all nodes with top nodes
    /(?<name>\w*) \((?<weight>\d*)\) -> (?<tops>.*)/.match(s)
  end.compact.each do |m| # set relations in nodes
    m[:tops].split(/,/).each do |top|
      bottom_node = nodes[m[:name].to_sym]
      top_node = nodes[top.strip.to_sym]
      bottom_node.add_child(top_node)
      top_node.add_parent(bottom_node)
    end
  end
  nodes.values
end

def weight_change_needed(node)
  return 0 if node.balanced?
  nodes = node.children
  outlier = outlier_child(node)
  other = outlier == nodes.first ? nodes.last : nodes.first
  other.tree_weight - outlier.tree_weight
end

def outlier_child(node, recurse: false)
  return nil if node.balanced?
  sorted = node.children.sort_by(&:tree_weight)
  outlier = sorted[0].tree_weight == sorted[1].tree_weight ? sorted[-1] : sorted[0]
  if recurse
    nested_outlier = outlier_child(outlier, recurse: true)
    nested_outlier.nil? ? outlier : nested_outlier
  else
    outlier
  end
end

# Declare the number of the AOC17 puzzle
PUZZLE = 7

# Declare all runs to be done for this puzzle
{
  test: {
    input: 'input_test.txt',
    target_root_name: 'tknk',
    target_new_weight: 60
  },
  puzzle: {
    input: 'input.txt',
    target_root_name: 'hmvwl',
    target_new_weight: 1853
  }
}.each do |run_name, run_pars|
  # skip run?
  if run_pars[:skip]
    puts "Skipped '#{run_name}'"
    next
  end

  # open input data and process it
  open(run_pars[:input]) do |input|
    # Read all input lines and sanitize
    data = input.readlines.map(&:strip)

    # Process data
    nodes = create_nodes(data)
    roots = nodes.select { |n| !n.parents? }
    root = roots.size != 1 ? nil : roots.first
    root_name = root.nil? ? 'Err: multi or none' : root.name

    new_weight = outlier_child(root, recurse: true).weight + weight_change_needed(root)

    # Print result
    success_msg1 = root_name == run_pars[:target_root_name] ? 'succeeded' : 'failed'
    success_msg2 = new_weight == run_pars[:target_new_weight] ? 'succeeded' : 'failed'
    puts "AOC17-#{PUZZLE}/#{run_name}1 #{success_msg1}: #{root_name} (Target: #{run_pars[:target_root_name]})"
    puts "AOC17-#{PUZZLE}/#{run_name}2 #{success_msg2}: #{new_weight} (Target: #{run_pars[:target_new_weight]})"
  end
end
