class Board
  def initialize
    @grid = {}
  end

  def add(x, y, data)
    @grid[coord_tag(x, y)] = data
  end

  def [](x, y)
    @grid[coord_tag(x, y)]
  end

  def []=(x, y, data)
    @grid[coord_tag(x, y)] = data
  end

  def neighbors(x, y)
    side_neighbors(x, y) + diagonal_neighbors(x, y)
  end

  def side_neighbors(x, y)
    [[-1, 0], [1, 0], [0, -1], [0, 1]].map { |c| @grid[coord_tag(x + c[0], y + c[1])] }.compact
  end

  def diagonal_neighbors(x, y)
    [[-1, -1], [1, -1], [-1, 1], [1, 1]].map { |c| @grid[coord_tag(x + c[0], y + c[1])] }.compact
  end

  def cell_count
    @grid.size
  end

  private def coord_tag(x, y)
    "cell_#{x}_#{y}".to_sym
  end
end
