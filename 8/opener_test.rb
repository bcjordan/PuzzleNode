require 'test/unit'
require 'opener'
require 'rubygems'
require 'shoulda-context'
require 'pp'

class OpenerTest < Test::Unit::TestCase
  context "a scrabble test input file" do
    setup do
      @opener = Opener.new "EXAMPLE_INPUT.json"

      @abc = ['a', 'b', 'c']
      @tiles = [['a', 3], ['b', 5], ['c', 6]]
      @nums1 = [1, 2, 3]
      @nums2 = [4, 5, 6]
    end

    should "have loaded" do
      assert @opener.hash
      
      assert_equal 1, @opener.board[0][0]
      assert_equal "gyre", @opener.dict[0]
      assert_equal ["i", 4], @opener.tiles.first
    end

    should "find letter values given letters and tiles" do
      values = @opener.generate_values(@abc, @tiles)
      assert_equal [3, 5, 6], values
    end

    should "handle letter repeats" do
      values = @opener.generate_values(@abc.dup.push('a'), @tiles)
      assert values.nil?

      values = @opener.generate_values(@abc.dup.push('a'), @tiles.dup.push(['a', 3]))

      assert values
    end

    should "get value of word placement" do
      value = @opener.placement_value(@nums1, @nums2)

      assert_equal value, 32
    end

    should "find the best score for a given 2d array" do
      assert_equal ["whiffling", 61, [6,0]], @opener.get_best(@opener.rotate_board_ccw)

      assert_equal ["whiffling", 65, [2,2]], @opener.get_best(@opener.board)
    end

    should "write a correct solution" do
      assert_equal File.open("EXAMPLE_OUTPUT.txt").readlines.to_s,
                   @opener.board_to_string(@opener.best_opener)
    end
  end

  context "a scrabble input file" do
    setup do
      @opener = Opener.new "INPUT.json"
    end

    should "print answer" do
      board = @opener.board_to_string(@opener.best_opener)
      #board = @opener.board_to_string(@opener.board)
      out = File.new("board.txt", "w")
      out.write(board)
      out.close
    end
  end
end