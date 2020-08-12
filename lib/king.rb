class King
  attr_reader :pos, :moves, :piece, :color

  def initialize(color, pos)
    if color == "white"
      @color = "white"
      @piece = "♔"
    else
      @color = "black"
      @piece = "♚"
    end
    @pos = pos
    @moves = set_moves
  end
  
  def set_moves
    [
      [@pos[0] - 1, @pos[1]],
      [@pos[0], @pos[1] + 1],
      [@pos[0] + 1, @pos[1]],
      [@pos[0], @pos[1] - 1],
    ]
  end
end