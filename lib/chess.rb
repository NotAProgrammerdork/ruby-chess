require 'yaml'
require_relative 'pawn.rb'
require_relative 'knight.rb'
require_relative 'bishop.rb'
require_relative 'rook.rb'
require_relative 'queen.rb'
require_relative 'king.rb'

class Chess
  def initialize
    clear
    puts "chess"
    puts
    puts "Do you want to load a game?(y/n)"
    load_game = gets.chomp.downcase
    clear
    return initialize unless load_game == "y" || load_game == "n"
    if load_game == "y"
      puts
      savings = Dir.entries("saves")
      savings.select! {|save| save[-5..] == ".yaml"}

      puts "Current savefiles: "
      if savings.empty?
        puts "  - No current savefiles"
        gets
        clear
      else
        savings.each do |saving|
          name = saving[0...-5]
          puts "  - " + name
        end
        puts
      end
      
      unless savings.empty?
        puts "Which file?"
        savefile = gets.chomp.downcase + ".yaml"
        return initialize unless savings.include?(savefile)
        savefile = File.open("saves/" + savefile)
      
        content = YAML.load(savefile)
        @points1 = content[:points][0]
        @points2 = content[:points][1]
        @dom_black = content[:dom][0]
        @dom_white = content[:dom][1]
        @dangers = content[:attack][0]
        @saviors = content[:attack][1]
        @white_castling = content[:castling][0]
        @black_castling = content[:castling][1]
        @white_left_rook = content[:white_rooks][0]
        @white_right_rook = content[:white_rooks][1]
        @black_left_rook = content[:black_rooks][0]
        @black_right_rook = content[:black_rooks][1]
        @passant = content[:passant]
        @first_player = content[:names][0]
        @second_player = content[:names][1]
        @white_king = content[:kings][0]
        @black_king = content[:kings][1]
        @white_pieces = content[:pieces][0]
        @black_pieces = content[:pieces][1]
        make_board
        
        savefile.close
        clear
        puts
        puts "\"save\" to save the game"
        puts "\"over\" to finish game by time"
        puts "\"leave\" to leave"
        gets
        clear
        return play(content[:current_player])
      end
    end
    each_piece
    make_board
    @points1 = 0; @points2 = 0
    @dom_black = []; @dom_white = []
    @dangers = []; @saviors = []
    @white_castling = true; @black_castling = true
    @white_left_rook = true; @white_right_rook = true
    @black_left_rook = true; @black_right_rook = true
    @passant = nil
    puts
    print "> First_player: "
    @first_player = gets.chomp
    @first_player = "White" if @first_player.length == 0
    print "> Second_player: "
    @second_player = gets.chomp
    @second_player = "Black" if @second_player.length == 0
    puts
    puts "\"save\" to save the game"
    puts "\"over\" to finish game by time"
    puts "\"leave\" to leave"
    gets
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
  
  def play(player, check=false)
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
    
    puts "-king in check-" if check
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
    print "> #{name}"
    print name == color.capitalize ? "\n" : " (#{color.capitalize})\n"
    print "   from: "
    from = gets.chomp.strip.downcase
    if from == "leave" || from == "over" || from == "save"
      return get_input(player, from)
    end
    from = get_input(player, from)
    
    if from[0].nil? || from[1].nil?
      return error(player, "That piece doesn't exist")
    end
    
    piece = @board[from[0]][from[1]]
    
    return error(player, "That piece doesn't exist") if piece == "-"
    return error(player, "It isn't your color") unless piece.color == color
    
    if is_it_in_danger?(my_king.pos, enemy_pieces, []) &&
       !@saviors.include?(piece)
      
      return error(player, "Your king is in check!")
    end
    
    piece.set_moves
    filter_moves(piece, color)
    check_if_pawn_can_move_two(piece) if piece.class == Pawn
    prepare_king_for_castling(piece) if piece.class == King
    
    unless @passant.nil? || @passant.color == "color"
      if @passant.pos == [piece.pos[0], piece.pos[1]+1]
        piece.moves << [piece.pos[0]-1, piece.pos[1]+1] if @passant.color == "black"
        piece.moves << [piece.pos[0]+1, piece.pos[1]+1] if @passant.color == "white"
      elsif @passant.pos == [piece.pos[0], piece.pos[1]-1]
        piece.moves << [piece.pos[0]-1, piece.pos[1]-1] if @passant.color == "black"
        piece.moves << [piece.pos[0]+1, piece.pos[1]-1] if @passant.color == "white"
      end
    end
    
    print "   to: "
    to = get_input(player, gets.chomp.downcase)
    return error(player, "Wrong movement") unless piece.moves.include?(to)
    
    change_position(player, my_king, enemy_pieces, piece, from, to, enemy_king, game)
  end
  
  def check_if_pawn_can_move_two(piece)
    if piece.color == "white" && piece.pos[0] == 6 ||
        piece.color == "black" && piece.pos[0] == 1

      filter_moves(piece, piece.color, @board, true)
    end
  end
  
  def prepare_king_for_castling(piece)
    bad_pieces = (piece.color == "white" ? @black_pieces : @white_pieces)
    return if is_it_in_danger?(piece.pos, bad_pieces, [])
    
    if !@white_left_rook && !@white_right_rook
      @white_castling = false
    elsif !@black_left_rook && !@black_right_rook
      @black_castling = false
    end

    if piece.color == "white" && @white_castling
      if @white_right_rook &&
          is_empty?([7,5]) && !is_it_in_danger?([7,5],bad_pieces,[]) && 
          is_empty?([7,6]) && !is_it_in_danger?([7,6],bad_pieces,[])

        piece.moves << [7,6]
      end
      if @white_left_rook &&
          is_empty?([7,1]) &&
          is_empty?([7,2]) && !is_it_in_danger?([7,2],bad_pieces,[]) &&
          is_empty?([7,3]) && !is_it_in_danger?([7,3],bad_pieces,[])

        piece.moves << [7,2]
      end
    elsif piece.color == "black" && @black_castling
      if @black_right_rook &&
          is_empty?([0,5]) && !is_it_in_danger?([0,5],bad_pieces,[]) &&
          is_empty?([0,6]) && !is_it_in_danger?([0,6],bad_pieces,[])
          
        piece.moves << [0,6]
      end
      if @black_left_rook &&
          is_empty?([0,1]) &&
          is_empty?([0,2]) && !is_it_in_danger?([0,2],bad_pieces,[]) &&
          is_empty?([0,3]) && !is_it_in_danger?([0,3],bad_pieces,[])

        piece.moves << [0,2]
      end
    end
  end
  
  def get_input(player, input)
    if input == "leave"
      if player == 1
        winning(2, "#{@first_player} leaves")
      else
        winning(1, "#{@second_player} leaves")
      end
    elsif input == "over"
      if @points1 > @points2split
        winning(1, "Time is over")
      elsif @points2 > @points1
        winning(2, "Time is over")
      else
        winning(nil, "Time is over")
      end
    elsif input == "save"
      save(player)
    else
      input = input.split ""
      temp = input[0]
      input[0] = [8,7,6,5,4,3,2,1].index(input[1].to_i)
      input[1] = Array("a".."h").index(temp)
      input
    end
  end

  def error(player, message)
    clear
    puts message
    play(player)
  end

  def change_position(player, king, enemies, piece, from, to, enemy_king, game)
    square = @board[to[0]][to[1]]
    unless @passant.nil?
      if to == [piece.pos[0]-1, piece.pos[1]+1] ||
          to == [piece.pos[0]+1, piece.pos[1]+1]
        
        square = @board[piece.pos[0]][piece.pos[1]+1]
      elsif to == [piece.pos[0]-1, piece.pos[1]-1] ||
          to == [piece.pos[0]+1, piece.pos[1]-1]
        
        square = @board[piece.pos[0]][piece.pos[1]-1]
      end
    end
    piece.pos = to
    piece.set_moves
    eaten = false
    
    execute_castling(piece, from, to) if piece.class == King || piece.class == Rook
    
    unless square == "-"
      if player == 1
        @points1 += square.value
        
        if square.class == Rook
          if square.pos == [0,7]
            @black_right_rook = false
          elsif square.pos == [0,0]
            @black_left_rook = false
          end
        end
        
        @black_pieces.delete(square)
        @dom_black << square
      else
        @points2 += square.value
        
        if square.class == Rook
          if square.pos == [7,7]
            @white_right_rook = false
          elsif square.pos == [7,0]
            @white_left_rook = false
          end
        end
        
        @white_pieces.delete(square)
        @dom_white << square
      end
      eaten = true
    end
    
    make_board
    if is_it_in_danger?(king.pos, enemies, [])
      piece.pos = from
      piece.set_moves
      if eaten
        if player == 1
          square = @dom_black.pop
          @black_pieces << square
          
          if square.class == Rook
            if square.pos == [0,7]
              @black_right_rook = true
            elsif square.pos == [0,0]
              @black_left_rook = true
            end
          end
          
          @points1 -= square.value
        else
          square = @dom_white.pop
          @white_pieces << square
                    
          if square.class == Rook
            if square.pos == [7,7]
              @white_right_rook = true
            elsif square.pos == [7,0]
              @white_left_rook = true
            end
          end
          
          @points2 -= square.value
        end
      end
      make_board
      return error(player, "Your king will be in check!")
    end
    
    @dangers.clear; @saviors.clear
    check_checkmate(enemy_king, game)
    return winning(player, "Checkmate!") if @saviors.empty? && !@dangers.empty?
    unless @dangers.empty?
      @dangers.each {|danger| filter_moves(danger, danger.color)}
    end
    
    if piece.class == Pawn
      if piece.color == "white" && to[0] == 0 ||
          piece.color == "black" && to[0] == 7
        #return promotion(player, piece)
        promotion(player, piece)
      end
    end
    
    @passant = nil if @passant
    if piece.class == Pawn
      if to == [from[0]-2, from[1]] ||
          to == [from[0]+2, from[1]]
      
        @passant = piece
      end
    end
    
    clear
    play(player == 1 ? 2 : 1, !@dangers.empty?)
  end
  
  def promotion(player, piece, error=false)
    clear
    puts
    puts (error ? "  Incorrect piece" : "  Pawn promotion")
    puts
    puts "> Knight  > Bishop"
    puts "> Rook    > Queen"
    puts
    print "Pawn => "
    option = gets.chomp.downcase
    case option
    when "knight"
      new_piece = Knight.new(piece.color, piece.pos)
    when "bishop"
      new_piece = Bishop.new(piece.color, piece.pos)
    when "rook"
      new_piece = Rook.new(piece.color, piece.pos)
    when "queen"
      new_piece = Queen.new(piece.color, piece.pos)
    else
      return promotion(player, piece, true)
    end
    #new_piece.filter_moves
    army = (piece.color == "white" ? @white_pieces : @black_pieces)
    army.delete(piece)
    army << new_piece
    make_board
    #clear
    #play(player == 1 ? 2 : 1)
  end
  
  def execute_castling(piece, from, to)
    if piece.class == King
      if piece.color == "white" && @white_castling
        move_rook(to, 7)
        @white_castling = false
      elsif piece.color == "black" && @black_castling
        move_rook(to, 0)
        @black_castling = false
      end
    elsif piece.class == Rook
      if piece.color == "white"
        if from == [7,7]
          @white_right_rook = false
        elsif from == [7,0]
          @white_left_rook = false
        end
      else
        if from == [0,7]
          @black_right_rook = false
        elsif from == [0,0]
          @black_left_rook = false
        end
      end
    end
  end
  
  def move_rook(to, row)
    if to == [row,6]
      rook = @board[row][7]
      rook.pos = [row,5]
      rook.set_moves
    elsif to == [row,2]
      rook = @board[row][0]
      rook.pos = [row,3]
      rook.set_moves
    end
  end
  
  def filter_moves(piece, color, board=@board, first_move=false)
    piece.moves.select! do |move|
      (0..7).include?(move[0]) &&
      (0..7).include?(move[1])
    end
    
=begin
    if piece.class == King
      bad_guys = (player == 1) ? @black_pieces : @white_pieces
      bad_guys.each do |enemy|
        enemy.moves.each do |move|
          piece.moves.delete(move) if piece.moves.include?(move)
        end
      end
=end

    if piece.class == Pawn && !piece.moves.empty?
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
  
  def winning(player, reason)
    clear
    winner = (player == 1) ? @first_player : @second_player
    puts reason
    puts (player.nil? ? "It's a draw!" : "Winner: #{winner}")
    puts
    puts " (#{@first_player}) #{@points1} <=> #{@points2} (#{@second_player})"
    make_board
    print_board
    gets
  end
  
  def is_it_in_danger?(king_pos, enemies, dangers=@dangers)
    enemies.each_with_index do |enemy, idx|
      filter_moves(enemy, enemy.color)
      enemy.moves.each do |move|
        if move == king_pos
          dangers << enemy
          break
        end
      end
    end
    !dangers.empty?
  end
  
  def check_checkmate(king, enemies)
    filter_moves(king, king.color)
    return unless is_it_in_danger?(king.pos, enemies, @dangers)
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
        choice = true unless is_it_in_danger?(king.pos, @dangers, [])
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
  
  def save(player)
    clear
    puts "Type a filename to save in a new file or in an existing one"
    puts
    savings = Dir.entries("saves")
    savings.select! {|save| save[-5..] == ".yaml"}

    puts "Current savefiles: "
    if savings.empty?
      puts "  - No current savefiles"
    else
      savings.each do |saving|
        name = saving[0...-5]
        puts "  - " + name
      end
    end
    puts

    print "> "
    input = gets.chomp.downcase + ".yaml"

    savefile = File.open("saves/" + input, "w+")
    content = {
      points: [@points1, @points2],
      dom: [@dom_black, @dom_white],
      attack: [@dangers, @saviors],
      castling: [@white_castling, @black_castling],
      white_rooks: [@white_left_rook, @white_right_rook],
      black_rooks: [@black_left_rook, @black_right_rook],
      passant: @passant,
      names: [@first_player, @second_player],
      kings: [@white_king, @black_king],
      pieces: [@white_pieces, @black_pieces],
      current_player: player
      }
    savefile.write(YAML.dump(content))
    savefile.close
  end
  
  def clear
    (system "cls") || (system "clear")
  end
end

Chess.new