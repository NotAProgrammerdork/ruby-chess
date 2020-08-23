class Queen
  attr_accessor :pos
  attr_reader :color, :piece, :value, :moves

  def initialize(color, pos)
    if color == "white"
      @color = "white"
      @piece = "♕"
    else
      @color = "black"
      @piece = "♛"
    end
    @pos = pos
    @value = 9
    set_moves
  end
  
  def set_moves
    @moves = [
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

  def to_s
    self.piece
  end
end