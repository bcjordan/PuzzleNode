require 'test/unit'
require 'encoder'
require 'rubygems'
require 'shoulda-context'
require 'pp'

class EncoderTest < Test::Unit::TestCase
  context "a string" do
    setup do
      @s = "Hello World\n"
    end

    should "be converted to binary" do
    #  assert_equal "0001001010100110001101100011011011110110000001001110101011110110010011100011011000100110", @s.to_binary
    end

    should "be hidden in a file" do
      @s.hide_in_file("input.bmp", "test_output.bmp")
      assert_equal "Hello World\n", String.read_from_file("test_output.bmp")
    end

    should "read from a hidden file" do
      pp String.read_from_file "sample_output.bmp"
    end
  end

  context "a string from a file" do
    setup do
      @s = File.open("input.txt").readlines.to_s
    end

    should "hide in a file" do
      pp @s
      @s.hide_in_file("input.bmp", "solution.bmp")

      pp "Result:", String.read_from_file("solution.bmp")
    end

    should "not be lame" do
        a = File.open("sample_output.bmp").readlines.to_s
        c = a.to_binary
        d = [c].pack('b*')
        
        b= File.new("sample_output_copy.bmp", "w")
        b.write(d)
        b.close

        pp String.read_from_file "sample_output_copy.bmp"

    end
  end
end
