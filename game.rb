# encoding: UTF-8
require_relative 'board.rb'
require 'yaml'

class Game
  
  def initialize
    @board = Board.new
  end
  
  def play
    system "clear" or system "cls"
    @player = true
    puts "Hello! Welcome to checkers, please enter in a move in the form of c2d1"
    puts "If you are jumping multiple pieces, please chain them in the form of f1d3b5"
    
    until game_over?
      @board.display
      
      input = get_valid_move
      input.first.perform_moves(@player, input.last)
      
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
      
      return [piece, all_positions] if piece.valid_move_seq?(@player, all_positions)
      
    rescue InvalidMoveError => e
      puts e
      retry
    end
    
  end
  
  def game_over?
    if no_pieces(!@player)
      puts "It's a tie!"
      return true
    elsif no_moves(!@player)
      return true
    end
    false
  end
  
  def no_pieces(color)
     !@board.grid.flatten.compact.any? { |p| p.color == color }
  end
  
  def no_moves(color)
    @board.grid.flatten.compact.all? { |p| p.moves.empty? && p.color == color }
  end
  
  def save_game
    save = [@board, @player]
    File.open("checkers_save", "w") do |f|
      f.puts save.to_yaml
    end
  end
  
  def load_game
    save = YAML::load(File.read("checkers_save")) if File.exist?("checkers_save")
    @board, @player = save[0], save[1]
  end
  
end

g = Game.new
g.play