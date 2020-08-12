class Pawn
  attr_accessor :pos
  attr_reader :moves, :piece, :color
  
  def initialize(color, pos)
    if color == "white"
      @color = "white"
      @piece = "♙"
    else
      @color = "black"
      @piece = "♟"
    end
    @pos = pos
    set_moves
  end
  
  def set_moves
    @moves = [[@pos[0]-1, @pos[1]]]
  end
end