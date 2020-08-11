class Chess
  def initialize
    make_board
    puts "chess"
    puts
    print "> First_player: "
    @first_player = gets.chomp
    print "> Second_player: "
    @second_player = gets.chomp
    print_board
  end

  def make_board
    @board = [["♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜"],
              ["♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟"],
              ["-", "-", "-", "-", "-", "-", "-", "-"],
              ["-", "-", "-", "-", "-", "-", "-", "-"],
              ["-", "-", "-", "-", "-", "-", "-", "-"],
              ["-", "-", "-", "-", "-", "-", "-", "-"],
              ["♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙"],
              ["♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"]]
  end

  def print_board
    puts
    num_row = 8
    @board.each do |row|
      print "  #{num_row}   "
      row.each_with_index do |square, idx|
        print square
        print (idx == row.length-1) ? "\n" : " "
      end
      num_row -= 1
    end
    puts
    puts "      a b c d e f g h"
  end
end

Chess.new