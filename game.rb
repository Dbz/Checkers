# encoding: UTF-8
require_relative 'board.rb'
require 'yaml'
require 'byebug'
class Game
  # class InvalidMoveError < StandardError
  # end
  
  def initialize
    @board = Board.new
  end
  
  def play
    system "clear" or system "cls"
    @player = true
    puts "Hello! Welcome to checkers, please enter in a move in the form of c2d1"
    puts "If you are jumping multiple pieces, please chain them in the form of f1d3b5"
    
    # @board[[4,1]] = Piece.new(false, [4, 1], @board)
    # @board[[1, 4]] = nil
    
    until game_over?
      @board.display
      
      input = get_valid_move
      input.first.perform_moves(input.last)
      
      system "clear" or system "cls"
      
      @player = !@player
    end
  end
  
  def get_valid_move
    begin
      puts "Please enter in your move:"
  
      letters = %w(a b c d e f g h)
      input = gets.chomp.downcase.split("")
      
      if input.first == "s"
        save_game
        return get_valid_move
      elsif input.first == "l"
        load_game
        system "clear" or system "cls"
        @board.display
        return get_valid_move
      end
  
      all_positions = []
      i = 0
      while i < input.count
        all_positions << [letters.index(input[i]), input[i+ 1].to_i - 1]
        i += 2
      end
  
      start = all_positions.shift
      piece = @board[start]

      # moves = piece.moves
      # jumps = jumping_moves(piece.color)
      
      return [piece, all_positions] if piece.valid_move_seq?(all_positions)
      
    rescue InvalidMoveError => e
      puts e
      retry
    end
  
      # if !moves.include? all_positions.first
#         raise InvalidMoveError.new "That piece can not move like that!"
#       elsif !jumps.empty? && !jumps.include?(all_positions.first)
#         p "jumps are: #{jumps}"
#         raise InvalidMoveError.new "If you can take a piece, you must"
#       else
#         # Determine if piece jumped as far as it can
#         b = @board.dup
#         cp = b[start]
#         if cp.jump_moves.include? all_positions.first # Piece move is a jump
#           cp.perform_moves! all_positions
#           unless cp.jump_moves.empty?
#             raise InvalidMoveError.new "You must jump as many tims as you can"
#           end
#         end
#
         # return [piece, all_positions]
#       end
    
  end
  
  def game_over?
    no_pieces(!@player) || no_moves(!@player)
  end
  
  def no_pieces(color)
     #p "no pieces: #{!@board.grid.flatten.compact.any? { |p| p.color == color }}"
     !@board.grid.flatten.compact.any? { |p| p.color == color }
  end
  
  def no_moves(color)
    #p "no moves: #{!@board.grid.flatten.compact.all? { |p| p.moves.empty? }}"
    @board.grid.flatten.compact.all? { |p| p.moves.empty? && p.color == color }
  end
  
  def save_game
    board = @board.to_yaml
    File.open("checkers_save", "w") do |f|
      f.puts board
    end
  end
  
  def load_game
    @board = YAML::load(File.read("checkers_save")) if File.exist?("checkers_save")
  end
  
end

g = Game.new
g.play