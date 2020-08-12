class Queen
  attr_reader :pos, :moves, :piece

  def initialize(color, pos)
    @piece = (color == "white") ? "♕" : "♛"
    @pos = pos
    @moves = set_moves
  end
  
  def set_moves
    [
      [@pos[0] - 1, @pos[1]],
      [@pos[0] - 2, @pos[1]],
      [@pos[0] - 3, @pos[1]],
      [@pos[0] - 4, @pos[1]],
      [@pos[0] - 5, @pos[1]],
      [@pos[0] - 6, @pos[1]],
      [@pos[0] - 7, @pos[1]],

      [@pos[0] - 1, @pos[1] + 1],
      [@pos[0] - 2, @pos[1] + 2],
      [@pos[0] - 3, @pos[1] + 3],
      [@pos[0] - 4, @pos[1] + 4],
      [@pos[0] - 5, @pos[1] + 5],
      [@pos[0] - 6, @pos[1] + 6],
      [@pos[0] - 7, @pos[1] + 7],

      [@pos[0], @pos[1] + 1],
      [@pos[0], @pos[1] + 2],
      [@pos[0], @pos[1] + 3],
      [@pos[0], @pos[1] + 4],
      [@pos[0], @pos[1] + 5],
      [@pos[0], @pos[1] + 6],
      [@pos[0], @pos[1] + 7],

      [@pos[0] + 1, @pos[1] + 1],
      [@pos[0] + 2, @pos[1] + 2],
      [@pos[0] + 3, @pos[1] + 3],
      [@pos[0] + 4, @pos[1] + 4],
      [@pos[0] + 5, @pos[1] + 5],
      [@pos[0] + 6, @pos[1] + 6],
      [@pos[0] + 7, @pos[1] + 7],

      [@pos[0] + 1, @pos[1]],
      [@pos[0] + 2, @pos[1]],
      [@pos[0] + 3, @pos[1]],
      [@pos[0] + 4, @pos[1]],
      [@pos[0] + 5, @pos[1]],
      [@pos[0] + 6, @pos[1]],
      [@pos[0] + 7, @pos[1]],

      [@pos[0] + 1, @pos[1] - 1],
      [@pos[0] + 2, @pos[1] - 2],
      [@pos[0] + 3, @pos[1] - 3],
      [@pos[0] + 4, @pos[1] - 4],
      [@pos[0] + 5, @pos[1] - 5],
      [@pos[0] + 6, @pos[1] - 6],
      [@pos[0] + 7, @pos[1] - 7],

      [@pos[0], @pos[1] - 1],
      [@pos[0], @pos[1] - 2],
      [@pos[0], @pos[1] - 3],
      [@pos[0], @pos[1] - 4],
      [@pos[0], @pos[1] - 5],
      [@pos[0], @pos[1] - 6],
      [@pos[0], @pos[1] - 7],

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