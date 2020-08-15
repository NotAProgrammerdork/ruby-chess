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
    @points1 = 0; @points2 = 0
    @dom_black = []; @dom_white = []
    @dangers = []; @saviors = []
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
    make_board
    print_board
    if player == 1
      name = @first_player
      color = "white"
      game = @white_pieces
      enemy_pieces = @black_pieces
      my_king = @white_king
      enemy_king = @black_king
    else
      name = @second_player
      color = "black"
      game = @black_pieces
      enemy_pieces = @white_pieces
      my_king = @black_king
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
    
    if is_it_in_danger?(my_king, enemy_pieces, []) &&
       !@saviors.include?(piece)
      
      return error(player, "Your king is in check!")
    end
    
    if piece.class == Pawn
      if piece.color == "white" && piece.pos[0] == 6 ||
          piece.color == "black" && piece.pos[0] == 1
        
        filter_moves(piece, color, @board, true)
      else
        filter_moves(piece, color)
      end
    else
      filter_moves(piece, color)
    end
    
    print "   to: "
    to = change_places(gets.chomp.downcase.split "")
    return error(player, "Wrong movement") unless piece.moves.include?(to)
    
    change_position(player, my_king, enemy_pieces, piece, from, to, enemy_king, game)
  end
  
  def change_places(ary)
    temp = ary[0]
    ary[0] = [8,7,6,5,4,3,2,1].index(ary[1].to_i)
    ary[1] = Array("a".."h").index(temp)
    ary
  end

  def error(player, message)
    clear
    puts message
    play(player)
  end

  def change_position(player, king, enemies, piece, from, to, enemy_king, game)
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
    if is_it_in_danger?(king, enemies, [])
      piece.pos = from
      piece.set_moves
      make_board
      return error(player, "Your king will be in check!")
    end
    @dangers.clear; @saviors.clear
    check_checkmate(enemy_king, game)
    return checkmate(player) if @saviors.empty? && !@dangers.empty?
    unless @dangers.empty?
      @dangers.each {|danger| filter_moves(danger, danger.color)}
    end
    clear
    play(player == 1 ? 2 : 1)
  end
  
  def filter_moves(piece, color, board=@board, first_move=false)
    piece.moves.select! do |move|
      (0..7).include?(move[0]) &&
      (0..7).include?(move[1])
    end

=begin
    if piece.class == King
      pieces = (player == 1) ? @black_pieces : @white_pieces
      bad_guys = []
      pieces.each do |enemy|
        enemy.moves.each do |move|
          if piece.moves.include?(move)
            piece.moves.delete(move)
            bad_guys << enemy
          end
        end
      end
=end

    if piece.class == Pawn
      if color == "white"
        piece.moves.clear unless is_empty?([piece.pos[0]-1,piece.pos[1]])
        piece.moves << [piece.pos[0]-1,piece.pos[1]+1] if is_enemy?("black",[piece.pos[0]-1,piece.pos[1]+1],board)
        piece.moves << [piece.pos[0]-1,piece.pos[1]-1] if is_enemy?("black",[piece.pos[0]-1,piece.pos[1]-1],board)
        piece.moves << [piece.pos[0]-2,piece.pos[1]] if first_move
      else
        piece.moves.clear unless is_empty?([piece.pos[0]+1,piece.pos[1]])
        piece.moves << [piece.pos[0]+1,piece.pos[1]+1] if is_enemy?("white",[piece.pos[0]+1,piece.pos[1]+1],board)
        piece.moves << [piece.pos[0]+1,piece.pos[1]-1] if is_enemy?("white",[piece.pos[0]+1,piece.pos[1]-1],board)
        piece.moves << [piece.pos[0]+2,piece.pos[1]] if first_move
      end
    
    elsif piece.class == Bishop
      (ur,dr,dl,ul) = Array.new(4, true)
      dup = piece.moves.dup
      piece.moves.clear
      dup.each do |move|
        if move[0] < piece.pos[0] && move[1] > piece.pos[1] # Up-Right
          if is_empty?(move, board) && ur
            piece.moves << move
          elsif ur
            piece.moves << move
            ur = false
          end
        elsif move[0] > piece.pos[0] && move[1] > piece.pos[1] # Down-Right
          if is_empty?(move, board) && dr
            piece.moves << move
          elsif dr
            piece.moves << move
            dr = false
          end
        elsif move[0] > piece.pos[0] && move[1] < piece.pos[1] # Down-Left
          if is_empty?(move, board) && dl
            piece.moves << move
          elsif dl
            piece.moves << move
            dl = false
          end
        elsif move[0] < piece.pos[0] && move[1] < piece.pos[1] # Up-Left
          if is_empty?(move, board) && ul
            piece.moves << move
          elsif ul
            piece.moves << move
            ul = false
          end
        end
      end
    
    elsif piece.class == Rook
      (u,r,d,l) = Array.new(4, true)
      dup = piece.moves.dup
      piece.moves.clear
      dup.each do |move|
        if move[0] < piece.pos[0] # Up
          if is_empty?(move, board) && u
            piece.moves << move
          elsif u
            piece.moves << move
            u = false
          end
        elsif move[1] > piece.pos[1] # Right
          if is_empty?(move, board) && r
            piece.moves << move
          elsif r
            piece.moves << move
            r = false
          end
        elsif move[0] > piece.pos[0] # Down
          if is_empty?(move, board) && d
            piece.moves << move
          elsif d
            piece.moves << move
            d = false
          end
        elsif move[1] < piece.pos[1] # Left
          if is_empty?(move, board) && l
            piece.moves << move
          elsif l
            piece.moves << move
            l = false
          end
        end
      end
    elsif piece.class == Queen
      (u,ur,r,dr,d,dl,l,ul) = Array.new(8, true)
      dup = piece.moves.dup
      piece.moves.clear
      dup.each do |move|
        if move[0] < piece.pos[0] && move[1] == piece.pos[1] # Up
          if is_empty?(move, board) && u
            piece.moves << move
          elsif u
            piece.moves << move
            u = false
          end
        elsif move[0] < piece.pos[0] && move[1] > piece.pos[1] # Up-Right
          if is_empty?(move) && ur
            piece.moves << move
          elsif ur
            piece.moves << move
            ur = false
          end
        elsif move[0] == piece.pos[0] && move[1] > piece.pos[1] # Right
          if is_empty?(move, board) && r
            piece.moves << move
          elsif r
            piece.moves << move
            r = false
          end
        elsif move[0] > piece.pos[0] && move[1] > piece.pos[1] # Down-Right
          if is_empty?(move) && dr
            piece.moves << move
          elsif dr
            piece.moves << move
            dr = false
          end
        elsif move[0] > piece.pos[0] && move[1] == piece.pos[1] # Down
          if is_empty?(move, board) && d
            piece.moves << move
          elsif d
            piece.moves << move
            d = false
          end
        elsif move[0] > piece.pos[0] && move[1] < piece.pos[1] # Down-Left
          if is_empty?(move) && dl
            piece.moves << move
          elsif dl
            piece.moves << move
            dl = false
          end
        elsif move[0] == piece.pos[0] && move[1] < piece.pos[1] # Left
          if is_empty?(move, board) && l
            piece.moves << move
          elsif l
            piece.moves << move
            l = false
          end
        elsif move[0] < piece.pos[0] && move[1] < piece.pos[1] # Up-Left
          if is_empty?(move) && ul
            piece.moves << move
          elsif ul
            piece.moves << move
            ul = false
          end
        end
      end
      
    end
    
    piece.moves.reject! {|move| is_ally?(color, move)}
    # piece.set_moves
    #p piece.moves
  end
  
  def is_enemy?(enemy_color, pos, board=@board)
    enemy = false
    if (0..7).include?(pos[0]) &&
       (0..7).include?(pos[1]) &&
       board[pos[0]][pos[1]] != "-" &&
       board[pos[0]][pos[1]].color == enemy_color
      
      enemy = true
    end
    enemy
  end
  
  def is_ally?(ally_color, pos, board=@board)
    ally = false
    if board[pos[0]][pos[1]] != "-" &&
       board[pos[0]][pos[1]].color == ally_color
      
      ally = true
    end
    ally
  end
    
  def is_empty?(pos, board=@board)
    board[pos[0]][pos[1]] == "-"
    
  end
  
  def checkmate(player)
    clear
    winner = (player == 1) ? @first_player : @second_player
    puts "Checkmate!"
    puts "Winner: #{winner}"
    make_board
    print_board
    gets
  end
  
  def is_it_in_danger?(king, enemies, dangers=@dangers)
    enemies.each do |enemy|
      enemy.set_moves
      filter_moves(enemy, enemy.color)
      enemy.moves.each do |move|
        if move == king.pos
          dangers << enemy
          break
        end
      end
    end
    !dangers.empty?
  end
  
  def check_checkmate(king, enemies)
    filter_moves(king, king.color)
    return unless is_it_in_danger?(king, enemies)
    allies = (king.color == "white") ? @white_pieces : @black_pieces
    allies.each_with_index do |ally, idx|
      ally.set_moves
      filter_moves(ally, king.color)
      
      pos_backup = []
      moves_backup = []
      
      @dangers.each do |danger|
        if ally.moves.include?(danger.pos)
          @saviors << ally
          break
        else
          pos_backup << danger.pos.dup
          moves_backup << danger.moves.dup
        end
      end
      
      next if @saviors.include?(ally)
    
      ally_pos_backup = ally.pos.dup
      ally_moves_backup = ally.moves.dup
      choice = false
      
      ally_moves_backup.each do |move|
        ally.pos = [move[0],move[1]]
        ally.set_moves
        filter_moves(ally, king.color)
        make_board
        
        @dangers.each do |danger|
          filter_moves(danger, king.color == "white" ? "black" : "white")
        end
        choice = true unless is_it_in_danger?(king, @dangers, [])
      end
      ally.pos = ally_pos_backup
      ally.moves.clear
      
      ally_moves_backup.each {|move| ally.moves << move}
      @saviors << ally if choice
      
      @dangers.each_with_index do |danger, idx|
        danger.pos = pos_backup[idx]
        danger.moves.clear
        moves_backup[idx].each {|move| danger.moves << move}
      end
      make_board
    end
  end
  
  def clear
    (system "cls") || (system "clear")
  end
end

Chess.new