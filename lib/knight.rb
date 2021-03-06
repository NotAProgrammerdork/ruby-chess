class Knight
  attr_accessor :pos
  attr_reader :color, :piece, :value, :moves

  def initialize(color, pos)
    if color == "white"
      @color = "white"
      @piece = "♘"
    else
      @color = "black"
      @piece = "♞"
    end
    @pos = pos
    @value = 3
    set_moves
  end
  
  def set_moves
    @moves = [
      [@pos[0] - 2, @pos[1] + 1],
      [@pos[0] - 1, @pos[1] + 2],
      [@pos[0] + 1, @pos[1] + 2],
      [@pos[0] + 2, @pos[1] + 1],
      [@pos[0] + 2, @pos[1] - 1],
      [@pos[0] + 1, @pos[1] - 2],
      [@pos[0] - 1, @pos[1] - 2],
      [@pos[0] - 2, @pos[1] - 1]
    ]
  end

  def to_s
    self.piece
  end
end