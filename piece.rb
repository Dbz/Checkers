# encoding: UTF-8
require_relative 'board.rb'
require 'byebug'

class InvalidMoveError < StandardError
end

class Piece
  
  VECTORS = [
    [1, 1],
    [1, -1],
    [-1, -1],
    [-1, 1]
  ]
  
  # Color is boolean
  attr_accessor :color, :pos, :is_king
  
  def initialize(color, pos, board, is_king = false)
    @color, @pos, @board, @is_king = color, pos, board, is_king
  end
  
  def pos=(value)
    @pos = value
    if color
      @is_king = true if @pos[0] == 0
    else
      @is_king = true if @pos[0] == 7
    end
    p "is king: #{@is_king}"
  end
  
  def slide_moves
    moves_arr = []
    get_vecs.each do |p|
      b = @board.dup
      target_pos = [p[0] + @pos[0], p[1] + @pos[1]]
      moves_arr << target_pos if b[@pos].perform_slide target_pos
    end
    moves_arr
  end
  
  def jump_moves
    moves_arr = []
    get_jump_vecs.each do |p|
      b = @board.dup
      target_pos = [p[0] + @pos[0], p[1] + @pos[1]]
      moves_arr << target_pos if b[@pos].perform_jump(target_pos)
    end
    moves_arr
  end
  
  def moves
    slide_moves + jump_moves
  end
  
  def perform_slide(pos)
    jump_dir = [pos[0] - @pos[0], pos[1] - @pos[1]]
    if possible_vector?(jump_dir) && in_bounds?(pos) && @board[pos].nil?
      @board[pos] = self
      @board[@pos] = nil
      self.pos = pos
      return true
    end
    false
  end
  
  def perform_jump(pos)
    jump_dir = [(pos[0] - @pos[0])/2, (pos[1] - @pos[1])/2]
    if possible_vector? jump_dir
      middle_pos = [@pos[0] + jump_dir[0], @pos[1] + jump_dir[1]]
      #byebug
      # in_bounds && middle position is not nil & occupied by opposite color & final pos is empty
      if in_bounds?(pos) && !@board[middle_pos].nil? && @board[middle_pos].color != color && @board[pos].nil?
        @board[pos] = self
        @board[@pos] = nil
        @board[middle_pos] = nil
        self.pos = pos
        return true
      end
    end
    false
  end
  
  def perform_moves(sequence)
    if valid_move_seq? sequence
      self.perform_moves! sequence
      true
    else
      false
    end
  end
  
  def perform_moves!(sequence)
    # Slide
    return true if perform_slide(sequence.first) if sequence.length == 1
    # Jump
    sequence.each do |j_pos|
      return false unless perform_jump(j_pos)
    end
  end 
  
  def valid_move_seq?(sequence)
    jumps = jumping_moves(@color)

    if !moves.include? sequence.first
      raise InvalidMoveError.new "That piece can not move like that!"
    elsif !jumps.empty? && !jumps.include?(sequence.first)
      p "valid_move_seq jumps are: #{jumps}"
      raise InvalidMoveError.new "If you can take a piece, you must!"
    elsif !@board.dup[@pos].perform_moves! sequence
      raise InvalidMoveError.new "Not a valid move sequence!"
    else
      # Determine if piece jumped as far as it can
      board_copy = @board.dup
      piece_copy = board_copy[@pos]
      if piece_copy.jump_moves.include? sequence.first # Piece move is a jump
        piece_copy.perform_moves! sequence
        unless piece_copy.jump_moves.empty?
          raise InvalidMoveError.new "You must jump as many times as you can!"
        end
      end
    end
    true
  end
  
  def jumping_moves(color)
    jumps = []
    @board.grid.flatten.compact.each do |p|
      next unless p.color == color
      jumps += p.jump_moves unless p.jump_moves.empty?
    end
    jumps
  end
  
  def dup(board)
    Piece.new(color, pos.dup, board, @is_king)
  end
    
  def in_bounds?(pos)
    pos.all?{|coord| coord.between?(0, 7) }
  end
  
  def possible_vector?(pos)
    vecs = get_vecs
    vecs.any? { |p| p == pos }
  end
  
  def get_vecs
    if is_king
      vecs = VECTORS
    elsif color
      vecs = VECTORS[2..-1]
    else
      vecs = VECTORS[0...2]
    end
    vecs
  end
  
  def get_jump_vecs
    vecs = get_vecs
    vecs.map { |x, y| [x * 2, y * 2] }
  end
  
  def to_s
    if is_king
      color ? "♚" : "♔"
    else
      color ? "●" : "○"
    end
  end
  
end

