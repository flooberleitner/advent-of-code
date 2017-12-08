class Node
  def initialize(name:, weight: 0)
    @name = name
    @weight = weight
    @children = []
    @parents = []
    @tree_weight = @weight
  end
  attr_reader :name, :weight, :children, :tree_weight

  def add_child(child)
    return if @children.include? child
    @children << child
    update_weight
  end

  def remove_child(child)
    @children.delete child
    update_weight
  end

  def children?
    @children.any?
  end

  def add_parent(parent)
    @parents << parent unless @parents.include? parent
  end

  def remove_parent(parent)
    @parents.delete parent
  end

  def parents?
    @parents.any?
  end

  def update_weight
    @tree_weight = @weight + @children.map(&:tree_weight).sum
    @parents.each(&:update_weight)
  end

  def balanced?
    @children.map(&:weight).uniq.size <= 1
  end
end
