require 'rubygems'
require 'json'
require 'pp'
require 'matrix'

class Opener
  attr_accessor :hash, :dict, :tiles, :board

  def initialize(filename)
    @hash = JSON.parse(File.open(filename).readlines.to_s)
    @board, @dict, @tiles = @hash['board'], @hash['dictionary'], @hash['tiles']

    # Turn @tiles into a tile value lookup table
    @tiles.map! { |tile| [tile[0..0], tile[1..1].to_i] }

    # Turn @board into a 2d array of integers
    @board.map! { |row| row.split(" ").map { |n| n.to_i } }


    # Generate mapping between all valid words and arrays of their letter values
    @words_to_values = []
    @dict.each { |w|
      w_to_values = [w, generate_values(w.split(""), @tiles.dup)]
      @words_to_values << w_to_values if w_to_values
    }
  end

  # Converts 2D board array to string, separating
  # columns with spaces and rows with newlines
  def board_to_string (board)
    board.map { |line| line.join " " }.join "\n"
  end

  # Finds best possible opener considering members @board and @words_to_values
  # Returns 2d array of multipliers and inserted letters
  def best_opener
    rotated = rotate_board_ccw

    best_move_normal = get_best(@board)
    best_move_ccw = get_best(rotated)

    if best_move_normal[1] > best_move_ccw[1]
      opener best_move_normal
    else
      opener best_move_ccw, true
    end
  end

  # Takes in [word, value, [row, col]], returns @board with word inserted.
  # Takes optional argument, whether this placement is vertical
  def opener (placement, rotation = false)
    letters = placement[0].split ""
    board = @board.dup
    row, col = placement[2][0], placement[2][1]
    unless rotation
      letters.each_with_index { |l, i| board[row][col + i] = l }
    else
      column = board[0].size - row - 1
      letters.each_with_index { |l, i| board[col + i][column] = l }
    end

    board
  end

  # Takes board, returns the best possible word and horizontal placement based on
  # @words_to_values. Returned is an array of [best word, score, [row, col]
  def get_best (board)
    word_leader = ["", -1]

    # Check horizontal placements
    board.each_with_index { |line, i|
      pp line
      @words_to_values.each { |w, v|
        if v # only consider words that can be covered with current tiles
          num_placements = (line.size - v.size) + 1
          
          num_placements.times { |j|
            value = placement_value(v, line[j, v.size])
            word_leader = [w, value, [i, j]] if value > word_leader[1]
            pp "Word: #{w}, value: #{value}, values: #{v}"
          }
        end
      }
    }

    word_leader
  end

  def rotate_board_ccw
    Matrix[*@board.map { |row| row.reverse }].transpose.to_a
  end

  def rotate_board_cw
    Matrix[*@board].transpose.to_a.map { |row| row.reverse }
  end

  # Takes in ordered values and their respective multipliers
  # Returns sum of total placement
  def placement_value (values, multipliers)
    values.zip(multipliers).map { |v, m| v * m }.inject(0) { |total, v| total + v }
  end

  # Takes in letters and tiles and returns hash associating array of letters
  # to array of letter values. Returns nil if tiles do not contain all letters
  def generate_values (letters, tiles)
    tiles = tiles.dup

    if letters.empty?
      []
    else
      tile_index = tiles.find_index { |t| t[0] == letters[0] }
      if tile_index
        tile = tiles.delete_at tile_index

        values = generate_values(letters[1..-1], tiles)

        if values
          values.unshift tile[1]
        else
          nil
        end
      else
        nil
      end
    end
  end
end