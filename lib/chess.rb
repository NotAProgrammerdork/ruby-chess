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
    @dom_black = []
    @dom_white = []
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

    @white_pieces.each do |piece|
      pos = piece.pos
      @board[pos[0]][pos[1]] = piece
    end
    @black_pieces.each do |piece|
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
    @white_king = King.new("white", [7,4])
    @white_pieces = [Pawn.new("white", [6,0]), Pawn.new("white", [6,1]),
                     Pawn.new("white", [6,2]), Pawn.new("white", [6,3]),
                     Pawn.new("white", [6,4]), Pawn.new("white", [6,5]),
                     Pawn.new("white", [6,6]), Pawn.new("white", [6,7]),
                     Knight.new("white", [7,1]), Knight.new("white", [7,6]),
                     Bishop.new("white", [7,2]), Bishop.new("white", [7,5]),
                     Rook.new("white", [7,0]), Rook.new("white", [7,7]),
                     Queen.new("white", [7,3]), @white_king]
    
    @black_king = King.new("black", [0,4])
    @black_pieces = [Pawn.new("black", [1,0]), Pawn.new("black", [1,1]),
                     Pawn.new("black", [1,2]), Pawn.new("black", [1,3]),
                     Pawn.new("black", [1,4]), Pawn.new("black", [1,5]),
                     Pawn.new("black", [1,6]), Pawn.new("black", [1,7]),
                     Knight.new("black", [0,1]), Knight.new("black", [0,6]),
                     Bishop.new("black", [0,2]), Bishop.new("black", [0,5]),
                     Rook.new("black", [0,0]), Rook.new("black", [0,7]),
                     Queen.new("black", [0,3]), @black_king]
  end
  
  def play(player)
    print_board
    if player == 1
      name = @first_player
      color = "white"
      game = @white_pieces
      enemy_king = @black_king
    else
      name = @second_player
      color = "black"
      game = @black_pieces
      enemy_king = @white_king
    end
    
    dom = (player == 1 ? @dom_black : @dom_white)
    points = (player == 1 ? @points1 : @points2)
    dom.each_with_index do |piece, idx|
      print piece
      if piece == dom.last
        puts " == #{points}"
        break
      end
      print (idx+1 % 5 == 0) ? "\n" : " "
    end
    puts
    puts "> #{name} (#{color.capitalize})"
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
    if !piece.moves.include?(to) ||
       enemy_king.pos == to
      
      return error(player, "Wrong movement") 
    end
    
    change_position(player, piece, to, enemy_king)
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

  def change_position(player, piece, to, enemy_king)
    piece.pos = to
    piece.set_moves
    square = @board[to[0]][to[1]]
    unless square == "-"
      if player == 1
        @points1 += square.value
        @black_pieces.delete(square)
        @dom_black << square
      else
        @points2 += square.value
        @white_pieces.delete(square)
        @dom_white << square
      end
    end
    make_board
    filter_king_mvs(player, enemy_king)
    return checkmate(player) if enemy_king.moves.empty?
    clear
    player == 1 ? play(2) : play(1)
  end
  
  def filter_king_mvs(player, enemy_king)
    pieces = (player == 1) ? @white_pieces : @black_pieces
    pieces.each do |ally|
      ally.moves.each do |move|
        enemy_king.moves.delete(move) if enemy_king.moves.include?(move)
      end
    end
    enemy_king.moves.reject! {|move| move[0] < 0 || move[1] < 0}
  end
  
  def checkmate(player)
    clear
    winner = (player == 1) ? @first_player : @second_player
    puts "Checkmate!"
    puts "Winner: #{winner}"
    print_board
  end
  
  def clear
    (system "cls") || (system "clear")
  end
end

Chess.new