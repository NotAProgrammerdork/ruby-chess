require_relative 'pawn.rb'
=begin
require_relative 'knight.rb'
require_relative 'bishop.rb'
require_relative 'rook.rb'
require_relative 'queen.rb'
require_relative 'king.rb'
=end
class Chess
  def initialize
    each_path
    make_board
    puts "chess"
    puts
    print "> First_player: "
    @first_player = gets.chomp
    print "> Second_player: "
    @second_player = gets.chomp
    print_board
    #play(@first_player)
  end

  def make_board
    @board = [["-", "-", "-", "-", "-", "-", "-", "-"],
              ["-", "-", "-", "-", "-", "-", "-", "-"],
              ["-", "-", "-", "-", "-", "-", "-", "-"],
              ["-", "-", "-", "-", "-", "-", "-", "-"],
              ["-", "-", "-", "-", "-", "-", "-", "-"],
              ["-", "-", "-", "-", "-", "-", "-", "-"],
              ["-", "-", "-", "-", "-", "-", "-", "-"],
              ["-", "-", "-", "-", "-", "-", "-", "-"]]
    @white_game.each do |piece|
      pos = piece.pos
      @board[pos[0]][pos[1]] = piece.piece
    end
    @black_game.each do |piece|
      pos = piece.pos
      @board[pos[0]][pos[1]] = piece.piece
    end
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
    puts
  end

  def each_path
    @white_game = [Pawn.new("white", [6,0]), Pawn.new("white", [6,1]),
                   Pawn.new("white", [6,2]), Pawn.new("white", [6,3]),
                   Pawn.new("white", [6,4]), Pawn.new("white", [6,5]),
                   Pawn.new("white", [6,6]), Pawn.new("white", [6,7]),
                   #Knight.new("white", [7,1]), Knight.new("white", [7,6]),
                   #Bishop.new("white", [7,2]), Bishop.new("white", [7,5]),
                   #Rook.new("white", [7,0]), Rook.new("white", [7,7]),
                   #Queen.new("white", [7,3]), King.new("white", [7,4])
                  ]

    @black_game = [Pawn.new("black", [1,0]), Pawn.new("black", [1,1]),
                   Pawn.new("black", [1,2]), Pawn.new("black", [1,3]),
                   Pawn.new("black", [1,4]), Pawn.new("black", [1,5]),
                   Pawn.new("black", [1,6]), Pawn.new("black", [1,7]),
                   #Knight.new("black", [0,1]), Knight.new("black", [0,6]),
                   #Bishop.new("black", [0,2]), Bishop.new("black", [0,5]),
                   #Rook.new("black", [0,0]), Rook.new("black", [0,7]),
                   #Queen.new("black", [0,3]), King.new("black", [0,4])
                  ]
  end

  def play(player)
    puts "> #{player}: "
    print "  "
    from = gets.chomp.downcase.split ""
    print "  "
    to = gets.chomp.downcase.split " "
    coords[1] = coords[1].to_i
    unless coords.length == 2 &&
           ("a".."h").include?(coords[0]) &&
           (1..8).include?(coords[1])

      return play(player)
    end
    x = Array("a".."h").index coords[0]
    y = 8 * coords[1] - coords[1]
  end
end

Chess.new