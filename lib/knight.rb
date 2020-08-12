class Knight
  attr_reader :pos, :moves, :piece

  def initialize(color, pos)
    @piece = (color == "white") ? "♘" : "♞"
    @pos = pos
    @moves = set_moves
  end
  
  def set_moves
    [
      [pos[0] - 2, pos[1] + 1],
      [pos[0] - 1, pos[1] + 2],
      [pos[0] + 1, pos[1] + 2],
      [pos[0] + 2, pos[1] + 1],
      [pos[0] + 2, pos[1] - 1],
      [pos[0] + 1, pos[1] - 2],
      [pos[0] - 1, pos[1] - 2],
      [pos[0] - 2, pos[1] - 1]
    ]
  end
end