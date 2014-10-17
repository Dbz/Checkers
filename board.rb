require_relative 'piece.rb'
require 'colorize'

class Board
  attr_accessor :grid
  
  def initialize(set_up = true)
    @grid = Array.new(8) { Array.new(8) { nil } }
    populate if set_up
  end
  
  def populate
    # Top color = false, Bottom = true
    @grid[0...8].each_with_index do |row, i|
      row.each_with_index do |pos, j|
        next if i > 2 && i < 5
        if (i.even? && j.odd?) || (i.odd? && j.even?)
          if i < 3
            @grid[i][j] = Piece.new(false, [i, j], self)
          else
            @grid[i][j] = Piece.new(true, [i, j], self)
          end
        end
      end
    end
  end
  
  def dup
    board_copy = Board.new(false)
    @grid.flatten.compact.each {|piece| board_copy[piece.pos] = piece.dup(board_copy) }
    board_copy
  end
  
  def [](pos)
    @grid[pos[0]][pos[1]]
  end
  
  def []=(pos, value)
    @grid[pos[0]][pos[1]] = value
  end
  
  def display
    letters = %w(a b c d e f g h)
    string = "   1  2  3  4  5  6  7  8    \n"
    @grid.each_with_index do |row, i|
      string += letters[i] + " "
      row.each_with_index do |piece, j|
        unless piece.nil?
          string += (" " + piece.to_s + " ").colorize(:background => color(i, j))
        else
          string += "   ".colorize(:background => color(i, j))
        end
      end
      string += "\n"
    end
    
    puts string
  end
  
  def color(i, j)
    if (i.even? && j.even?) || (i.odd? && j.odd?)
      :brown
    else
      :white
    end
  end
  
end