##
# A simple double linked list implementation.
class LinkedList
  ##
  # Create new list elements can added to
  def initialize
    @head = nil
    @tail = nil
    @size = 0
  end
  attr_reader :head, :tail
  alias first head
  alias last tail

  ##
  # Add +object+ at first position in list.
  # Returns the node the object was added to.
  def add_first(object)
    new_node = Node.new(object, parent_list: self)
    if @head
      new_node.insert_before(@head)
      @head = new_node
    else
      @head = @tail = new_node
    end
    @size += 1
    new_node
  end

  ##
  # Add +object+ at last position in list.
  # Returns the node the object was added to.
  def add_last(object)
    new_node = Node.new(object, parent_list: self)
    if @tail
      new_node.insert_after(@tail)
      @tail = new_node
    else
      @head = @tail = new_node
    end
    @size += 1
    new_node
  end

  ##
  # Call given block for each element in list once
  def each(&block)
    raise 'Need block that accepts nodes' unless block
    raise 'Block requires 1 parameter accepting the node' if block.arity.zero?

    cur_node = @head
    loop do
      yield(cur_node)
      break if cur_node == @tail
      break unless cur_node.next
      cur_node = cur_node.next
    end
  end

  ##
  # Callback the will be called by nodes upon beeing removed from the list.
  # Used by the LinkedList to do some house keeping.
  def node_will_be_removed(node)
    @size -= 1
    if node == @head
      @head = node.next
    elsif node == @tail
      @tail = node.prev
    end
  end

  ##
  # Basic class for double linked nodes.
  class Node
    ##
    # Create new Node instance.
    # +object# can be accessed with #data.
    # If a +parent_list+ is provided, the node will
    # notify the parent list in case of certain events, like the
    # node beeing deleted.
    def initialize(object, parent_list: nil)
      @prev = nil
      @next = nil
      @data = object
      @parent_list = parent_list
    end
    attr_accessor :data, :prev, :next

    ##
    # Insert self before +other+ node.
    def insert_before(other)
      @next = other
      @prev = other.prev
      @prev.next = self if @prev
      other.prev = self
      self
    end

    ##
    # Insert self after +other+ node.
    def insert_after(other)
      @prev = other
      @next = other.next
      @next.prev = self if @next
      other.next = self
      self
    end

    ##
    # Delete self from list.
    # Returns the object that was stored in node data.
    def delete
      @parent_list.node_will_be_removed(self) if @parent_list
      @next.prev = @prev if @next
      @prev.next = @next if @prev
      @prev = nil
      @next = nil
      data = @data
      @data = nil
      data
    end

    def to_s
      "d=#{@data}, p=#{@prev.data if @prev}, n=#{@next.data if @next}"
    end
  end
end
