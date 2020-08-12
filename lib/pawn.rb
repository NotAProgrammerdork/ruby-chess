class Pawn
  attr_accessor :pos
  attr_reader :color, :piece, :value, :moves
  
  def initialize(color, pos)
    if color == "white"
      @color = "white"
      @piece = "♙"
    else
      @color = "black"
      @piece = "♟"
    end
    @pos = pos
    @value = 1
    set_moves
  end
  
  def set_moves
    if @color == "white"
      @moves = [[@pos[0]-1, @pos[1]]]
    else
      @moves = [[@pos[0]+1, @pos[1]]]
    end
  end

  def to_s
    self.piece
  end
end