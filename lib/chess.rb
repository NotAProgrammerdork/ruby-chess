require_relative 'pawn.rb'
require_relative 'knight.rb'
require_relative 'bishop.rb'
require_relative 'rook.rb'
require_relative 'queen.rb'
require_relative 'king.rb'

class Chess
  def initialize
    clear
    each_piece
    make_board
    @points1 = 0
    @points2 = 0
    puts "chess"
    puts
    print "> First_player: "
    @first_player = gets.chomp
    print "> Second_player: "
    @second_player = gets.chomp
    clear
    play(1)
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
      @board[pos[0]][pos[1]] = piece
    end
    @black_game.each do |piece|
      pos = piece.pos
      @board[pos[0]][pos[1]] = piece
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

  def each_piece
    @white_game = [Pawn.new("white", [6,0]), Pawn.new("white", [6,1]),
                   Pawn.new("white", [6,2]), Pawn.new("white", [6,3]),
                   Pawn.new("white", [6,4]), Pawn.new("white", [6,5]),
                   Pawn.new("white", [6,6]), Pawn.new("white", [6,7]),
                   Knight.new("white", [7,1]), Knight.new("white", [7,6]),
                   Bishop.new("white", [7,2]), Bishop.new("white", [7,5]),
                   Rook.new("white", [7,0]), Rook.new("white", [7,7]),
                   Queen.new("white", [7,3]), King.new("white", [7,4])
                  ]

    @black_game = [Pawn.new("black", [1,0]), Pawn.new("black", [1,1]),
                   Pawn.new("black", [1,2]), Pawn.new("black", [1,3]),
                   Pawn.new("black", [1,4]), Pawn.new("black", [1,5]),
                   Pawn.new("black", [1,6]), Pawn.new("black", [1,7]),
                   Knight.new("black", [0,1]), Knight.new("black", [0,6]),
                   Bishop.new("black", [0,2]), Bishop.new("black", [0,5]),
                   Rook.new("black", [0,0]), Rook.new("black", [0,7]),
                   Queen.new("black", [0,3]), King.new("black", [0,4])
                  ]
  end

  def play(player)
    print_board
    if player == 1
      name = @first_player
      color = "white"
      game = @white_game
      points = @points1
    else
      name = @second_player
      color = "black"
      game = @black_game
      points = @points2
    end
    
    puts
    puts "> #{name} ="
    print "   from: "
    from = change_places(gets.chomp.strip.downcase.split "")
    
    if from[0].nil? || from[1].nil?
      return error(player, "That piece doesn't exist")
    end
    
    piece = @board[from[0]][from[1]]
    return error(player, "That piece doesn't exist") if piece == "-"
    return error(player, "It isn't your color") unless piece.color == color
    
    if piece.class == Pawn
      if color == "white"
        piece.moves = [] if @board[from[0]-1][from[1]] != "-"
        piece.moves << [from[0]-1,from[1]+1] if @board[from[0]-1][from[1]+1] != "-"
        piece.moves << [from[0]-1,from[1]-1] if @board[from[0]-1][from[1]-1] != "-"
      else
        piece.moves = [] if @board[from[0]+1][from[1]] != "-"
        piece.moves << [from[0]+1,from[1]+1] if @board[from[0]+1][from[1]+1] != "-"
        piece.moves << [from[0]+1,from[1]-1] if @board[from[0]+1][from[1]-1] != "-"
      end
    end
    
    print "   to: "
    to = change_places(gets.chomp.downcase.split "")
    return error(player, "Wrong movement") unless piece.moves.include?(to)
    
    change_position(player, piece, to, points)
  end

  def change_places(ary)
    temp = ary[0]
    ary[0] = ary[1].to_i
    ary[1] = temp
    ary[0] = [8,7,6,5,4,3,2,1].index(ary[0])
    ary[1] = Array("a".."h").index(ary[1])
    ary
  end

  def error(player, message)
    clear
    puts message
    play(player)
  end

  def change_position(player, piece, to, points)
    piece.pos = to
    piece.set_moves
    square = @board[to[0]][to[1]]
    points += square.value unless square == "-"
    make_board
    clear
    player == 1 ? play(2) : play(1)
  end
  
  def clear
    (system "cls") || (system "clear")
  end
end

Chess.new