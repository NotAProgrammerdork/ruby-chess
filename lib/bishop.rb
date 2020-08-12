class Bishop
  attr_reader :pos, :moves, :piece, :color

  def initialize(color, pos)
    if color == "white"
      @color = "white"
      @piece = "♗"
    else
      @color = "black"
      @piece = "♝"
    end
    @pos = pos
    @moves = set_moves
  end
  
  def set_moves
    [
      [@pos[0] - 1, @pos[1] + 1],
      [@pos[0] - 2, @pos[1] + 2],
      [@pos[0] - 3, @pos[1] + 3],
      [@pos[0] - 4, @pos[1] + 4],
      [@pos[0] - 5, @pos[1] + 5],
      [@pos[0] - 6, @pos[1] + 6],
      [@pos[0] - 7, @pos[1] + 7],

      [@pos[0] + 1, @pos[1] + 1],
      [@pos[0] + 2, @pos[1] + 2],
      [@pos[0] + 3, @pos[1] + 3],
      [@pos[0] + 4, @pos[1] + 4],
      [@pos[0] + 5, @pos[1] + 5],
      [@pos[0] + 6, @pos[1] + 6],
      [@pos[0] + 7, @pos[1] + 7],

      [@pos[0] + 1, @pos[1] - 1],
      [@pos[0] + 2, @pos[1] - 2],
      [@pos[0] + 3, @pos[1] - 3],
      [@pos[0] + 4, @pos[1] - 4],
      [@pos[0] + 5, @pos[1] - 5],
      [@pos[0] + 6, @pos[1] - 6],
      [@pos[0] + 7, @pos[1] - 7],

      [@pos[0] - 1, @pos[1] - 1],
      [@pos[0] - 2, @pos[1] - 2],
      [@pos[0] - 3, @pos[1] - 3],
      [@pos[0] - 4, @pos[1] - 4],
      [@pos[0] - 5, @pos[1] - 5],
      [@pos[0] - 6, @pos[1] - 6],
      [@pos[0] - 7, @pos[1] - 7]
    ]
  end
end