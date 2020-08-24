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
    puts "   ____ _"
    puts "  / ___| |__   ___  ___ ___"
    puts " | |   | '_ \\ / _ \\/ __/ __|"
    puts " | |___| | | |  __/\\__ \\__ \\"
    puts "  \\____|_| |_|\\___||___/___/\n\n"
    puts "      <<Press enter>>"
    gets
    load_game? == "y" ? load_game : regular_game
  end
  
  def load_game?
    clear
    puts
    puts "Do you want to load a game?(y/n)"
    load_s = gets.chomp.downcase
    if load_s == "y" || load_s == "n"
      clear
      load_s
    else
      load_game?
    end
  end
  
  def load_game
    puts
    Dir.mkdir("saves") unless Dir.exist?("saves")
    savings = Dir.entries("saves").select! {|save| save[-5..] == ".yaml"}

    puts "Current savefiles: "
    if savings.empty?
      puts "  - No current savefiles\n"
      gets
      clear
    else
      savings.each do |saving|
        name = saving[0...-5]
        puts "  - " + name
      end
      puts
    end

    return regular_game if savings.empty?
    puts "Which file?"
    savefile = gets.chomp.downcase + ".yaml"
    return load_game? unless savings.include?(savefile)
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
    puts "\n\"save\" to save the game"
    puts "\"over\" to finish game by time"
    puts "\"leave\" to leave\n"
    gets
    clear
    return play(content[:current_player])
  end
  
  def regular_game
    declare_game
    make_board
    computer_to_play
    puts
    print "> First_player: "
    @first_player = gets.chomp
    @first_player = "White" if @first_player.length == 0
    if @comp
      puts "> Second_player: Computer"
      @second_player = "Computer"
    else
      print "> Second_player: "
      @second_player = gets.chomp
      @second_player = "Black" if @second_player.length == 0
    end
    puts "\n\"save\" to save the game"
    puts "\"over\" to finish game by time"
    puts "\"leave\" to leave"
    gets
    clear
    play(1)
  end
  
  def computer_to_play
    puts "\nDo you want computer to play?(y/n)"
    @comp = gets.chomp.downcase
    @comp = true if @comp == "y"
    @comp = false if @comp == "n"
    computer_to_play unless @comp == true || @comp == false
    clear
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
    row_num = 8
    @board.each do |row|
      print "  #{row_num}   "
      row.each_with_index do |square, idx|
        print square
        print (idx == row.length-1 ? "\n" : " ")
      end
      row_num -= 1
    end
    puts "\n      a b c d e f g h\n"
  end

  def declare_game
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
                     Queen.new("black", [5,6]), @black_king]
    
    @points1 = 0; @points2 = 0
    @dom_black = []; @dom_white = []
    @dangers = []; @saviors = []
    @white_castling = true; @black_castling = true
    @white_left_rook = true; @white_right_rook = true
    @black_left_rook = true; @black_right_rook = true
    @passant = nil
  end
  
  def play(player, check=false)
    make_board
    print_board
    if player == 1
      @name = @first_player
      @color = "white"
      @game = @white_pieces
      @enemy_pieces = @black_pieces
      @my_king = @white_king
      @enemy_king = @black_king
    else
      @name = @second_player
      @color = "black"
      @game = @black_pieces
      @enemy_pieces = @white_pieces
      @my_king = @black_king
      @enemy_king = @white_king
    end
    
    puts "\n-king in check-" if check
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
    print "\n> #{@name}"
    print (@name == @color.capitalize ? "\n" : " (#{@color.capitalize})\n")
    print "   from: "
    
    if @name == "Computer"
      piece = computed_piece
      @from = piece.pos
      print Array("a".."h")[@from[1]]
      puts [8,7,6,5,4,3,2,1][@from[0]]
    else
      @from = gets.chomp.strip.downcase
      if @from == "leave" || @from == "over" || @from == "save"
        return get_input(player, @from)
      end
      @from = get_input(player, @from)

      if @from[0].nil? || @from[1].nil?
        return error(player, "That piece doesn't exist")
      end
    
      piece = @board[@from[0]][@from[1]]

      return error(player, "That piece doesn't exist") if piece == "-"
      return error(player, "It isn't your color") unless piece.color == @color

      if is_it_in_danger? &&
         !@saviors.include?(piece)

        return error(player, "Your king is in check!")
      end
      piece.set_moves
      filter_moves(piece)
    end
    
    check_if_pawn_can_move_two(piece) if piece.class == Pawn
    prepare_king_for_castling if piece.class == King
    
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
    if @name == "Computer"
      computed_to(piece)
      print Array("a".."h")[@to[1]]
      puts [8,7,6,5,4,3,2,1][@to[0]]
    else
      @to = gets.chomp.downcase
      if @to == "leave" || @to == "over" || @to == "save"
        return get_input(player, @to)
      end
      @to = get_input(player, @to)
      return error(player, "Wrong movement") unless piece.moves.include?(@to)
    end
    
    change_position(player, piece)
  end
  
  def computed_piece
    from = []
    from << Array(0..7).sample << Array(0..7).sample
    piece = @board[from[0]][from[1]]
    if piece == "-" ||
        piece.color != @color ||
        is_it_in_danger? &&
        !@saviors.include?(piece)
      
      return computed_piece
    end
    piece.set_moves
    filter_moves(piece)
    return computed_piece if piece.moves.empty?
    piece
  end
  
  def computed_to(piece)
    @to = piece.moves.sample
    backup_pos = piece.pos.dup
    backup_moves = piece.moves.dup
    piece.pos = @to
    piece.set_moves
    make_board
    if is_it_in_danger?
      piece.pos = backup_pos
      piece.moves.clear
      backup_moves.each do |move|
        piece.moves << move
      end
      make_board
      return computed_to(piece)
    end
    piece.pos = backup_pos
    backup_moves.each do |move|
      piece.moves << move
    end
    make_board
  end
  
  def check_if_pawn_can_move_two(piece)
    if piece.color == "white" && piece.pos[0] == 6 ||
        piece.color == "black" && piece.pos[0] == 1

      filter_moves(piece, @board, true)
    end
  end
  
  def prepare_king_for_castling
    return if is_it_in_danger?
    
    if !@white_left_rook && !@white_right_rook
      @white_castling = false
    elsif !@black_left_rook && !@black_right_rook
      @black_castling = false
    end

    if @color == "white" && @white_castling
      if @white_right_rook &&
          is_empty?([7,5]) && !is_it_in_danger?([7,5]) && 
          is_empty?([7,6]) && !is_it_in_danger?([7,6])

        @my_king.moves << [7,6]
      end
      if @white_left_rook &&
          is_empty?([7,1]) &&
          is_empty?([7,2]) && !is_it_in_danger?([7,2]) &&
          is_empty?([7,3]) && !is_it_in_danger?([7,3])

        @my_king.moves << [7,2]
      end
    elsif @color == "black" && @black_castling
      if @black_right_rook &&
          is_empty?([0,5]) && !is_it_in_danger?([0,5]) &&
          is_empty?([0,6]) && !is_it_in_danger?([0,6])
          
        @my_king.moves << [0,6]
      end
      if @black_left_rook &&
          is_empty?([0,1]) &&
          is_empty?([0,2]) && !is_it_in_danger?([0,2]) &&
          is_empty?([0,3]) && !is_it_in_danger?([0,3])

        @my_king.moves << [0,2]
      end
    end
  end
  
  def get_input(player, input)
    if input == "leave"
      if player == 1
        winning(2, "#{@name} leaves")
      else
        winning(1, "#{@name} leaves")
      end
    elsif input == "over"
      if @points1 > @points2
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

  def change_position(player, piece)
    square = @board[@to[0]][@to[1]]
    unless @passant.nil?
      if @to == [piece.pos[0]-1, piece.pos[1]+1] ||
          @to == [piece.pos[0]+1, piece.pos[1]+1]
        
        square = @board[piece.pos[0]][piece.pos[1]+1]
      elsif @to == [piece.pos[0]-1, piece.pos[1]-1] ||
          @to == [piece.pos[0]+1, piece.pos[1]-1]
        
        square = @board[piece.pos[0]][piece.pos[1]-1]
      end
    end
    piece.pos = @to
    piece.set_moves
    eaten = false
    
    execute_castling(piece) if piece.class == King || piece.class == Rook
    
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
    if @enemy_pieces.length == 1
      @enemy_king.moves.each do |move|
        danger = is_it_in_danger?(move, @game)
        break unless danger
        if move == @enemy_king.moves.last
          return winning(nil, "Drown!")
        end
      end
    end
    if is_it_in_danger? &&
        (@comp == false ||
        @comp == true && player == 1)
      
      piece.pos = @from
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
    check_checkmate
    return winning(player, "Checkmate!") if @saviors.empty? && !@dangers.empty?
    unless @dangers.empty?
      @dangers.each {|danger| filter_moves(danger)}
    end
    
    if piece.class == Pawn
      if piece.color == "white" && @to[0] == 0 ||
          piece.color == "black" && @to[0] == 7
        #return promotion(player, piece)
        promotion(player, piece)
      end
    end
    
    @passant = nil if @passant
    if piece.class == Pawn
      if @to == [@from[0]-2, @from[1]] ||
          @to == [@from[0]+2, @from[1]]
      
        @passant = piece
      end
    end
    
    gets if @comp == true && player == 2
    clear
    play(player == 1 ? 2 : 1, !@dangers.empty?)
  end
  
  def promotion(player, piece, error=false)
    clear
    puts "\n  " + (error ? "Incorrect piece" : "Pawn promotion") + "\n"
    puts "> Knight  > Bishop"
    puts "> Rook    > Queen\n"
    print "Pawn => "
    if @comp && player == 2
      option = ["knight", "bishop", "rook", "queen"].sample
    else
      option = gets.chomp.downcase
    end
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
    @game.delete(piece)
    @game << new_piece
    make_board
    #clear
    #play(player == 1 ? 2 : 1)
  end
  
  def execute_castling(piece)
    if piece.class == King
      if piece.color == "white" && @white_castling
        move_rook(7)
        @white_castling = false
      elsif piece.color == "black" && @black_castling
        move_rook(0)
        @black_castling = false
      end
    elsif piece.class == Rook
      if piece.color == "white"
        if @from == [7,7]
          @white_right_rook = false
        elsif @from == [7,0]
          @white_left_rook = false
        end
      else
        if @from == [0,7]
          @black_right_rook = false
        elsif from == [0,0]
          @black_left_rook = false
        end
      end
    end
  end
  
  def move_rook(row)
    if @to == [row,6]
      rook = @board[row][7]
      rook.pos = [row,5]
      rook.set_moves
    elsif @to == [row,2]
      rook = @board[row][0]
      rook.pos = [row,3]
      rook.set_moves
    end
  end
  
  def filter_moves(piece, board=@board, first_move=false)
    piece.moves.select! do |move|
      (0..7).include?(move[0]) &&
      (0..7).include?(move[1])
    end

    if piece.class == Pawn && !piece.moves.empty?
      if piece.color == "white"
        piece.moves.clear unless is_empty?([piece.pos[0]-1,piece.pos[1]])
        piece.moves << [piece.pos[0]-1,piece.pos[1]+1] if is_enemy?([piece.pos[0]-1,piece.pos[1]+1],board)
        piece.moves << [piece.pos[0]-1,piece.pos[1]-1] if is_enemy?([piece.pos[0]-1,piece.pos[1]-1],board)
        
        if first_move && @board[piece.pos[0]-2][piece.pos[1]] == "-"
          piece.moves << [piece.pos[0]-2,piece.pos[1]]
        end
      else
        piece.moves.clear unless is_empty?([piece.pos[0]+1,piece.pos[1]])
        piece.moves << [piece.pos[0]+1,piece.pos[1]+1] if is_enemy?([piece.pos[0]+1,piece.pos[1]+1],board)
        piece.moves << [piece.pos[0]+1,piece.pos[1]-1] if is_enemy?([piece.pos[0]+1,piece.pos[1]-1],board)
        
        if first_move && @board[piece.pos[0]+2][piece.pos[1]] == "-"
          piece.moves << [piece.pos[0]+2,piece.pos[1]]
        end
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
    piece.moves.reject! {|move| is_ally?(piece.color, move)}
  end
  
  def is_enemy?(pos, board=@board)
    enemy = false
    if (0..7).include?(pos[0]) &&
       (0..7).include?(pos[1]) &&
       board[pos[0]][pos[1]] != "-" &&
       board[pos[0]][pos[1]].color != @color
      
      enemy = true
    end
    enemy
  end
  
  def is_ally?(color, pos, board=@board)
    ally = false
    if board[pos[0]][pos[1]] != "-" &&
       board[pos[0]][pos[1]].color == color
      
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
  
  def is_it_in_danger?(king_pos=@my_king.pos, enemy_pieces=@enemy_pieces, dangers=[])
    enemy_pieces.each_with_index do |enemy, idx|
      enemy.set_moves
      filter_moves(enemy)
      enemy.moves.each do |move|
        if move == king_pos
          dangers << enemy
          break
        end
      end
    end
    !dangers.empty?
  end
  
  def check_checkmate
    filter_moves(@enemy_king)
    return unless is_it_in_danger?(@enemy_king.pos, @game, @dangers)
    @enemy_pieces.each_with_index do |ally, idx|
      ally.set_moves
      filter_moves(ally)
      
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
        filter_moves(ally)
        make_board
        
        @dangers.each do |danger|
          filter_moves(danger)
        end
        choice = true unless is_it_in_danger?(@enemy_king.pos, @dangers)
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
    puts "Type a filename to save in a new file or in an existing one\n"
    savings = Dir.entries("saves").select {|save| save[-5..] == ".yaml"}

    puts "Current savefiles: "
    if savings.empty?
      puts "  - No current savefiles"
    else
      savings.each do |saving|
        name = saving[0...-5]
        puts "  - " + name
      end
    end

    print "\n> "
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