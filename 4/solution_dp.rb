require 'pp'

def longest_sub_rec (word, word2, initial = 0)
  if word == "" or word2 == ""
    initial
  else
    search = word2.index word[0..0]
    if search
      use = longest_sub_rec(word[1..-1], word2[search+1..-1], initial + 1)
      continue = longest_sub_rec(word[1..-1], word2, initial)
      [use, continue].max
      end 
    else
      longest_sub_rec(word[1..-1], word2, initial)
    end
  end
end

def longest_sub_dynamic(a, b)
    lengths = Array.new(a.size+1) { Array.new(b.size+1) { 0 } }
    # row 0 and column 0 are initialized to 0 already
    a.split('').each_with_index { |x, i|
        b.split('').each_with_index { |y, j|
            if x == y
                lengths[i+1][j+1] = lengths[i][j] + 1
            else
                lengths[i+1][j+1] = \
                    [lengths[i+1][j], lengths[i][j+1]].max
            end
        }
    }
    # read the substring out from the matrix
    result = 0
    x, y = a.size, b.size
    while x != 0 and y != 0
        if lengths[x][y] == lengths[x-1][y]
            x -= 1
        elsif lengths[x][y] == lengths[x][y-1]
            y -= 1
        else
            # assert a[x-1] == b[y-1]
            result += 1
            x -= 1
            y -= 1
        end
    end
    result
end

words_file = 'INPUT.txt'
solution_file = 'OUTPUT.faster.txt'

solution_string = ""

words = File.read(words_file).split

num_words = words[0].to_i

num_words.times do |i|
  word, word1, word2 = words[i*3+1], words[i*3+2], words[i*3+3]
  word1_score = lcs(word, word1)
  word2_score = lcs(word, word2)

  if word1_score > word2_score
    pp word1
    solution_string << "#{word1}\n"
  else
    pp word2
    solution_string << "#{word2}\n"
  end
end

open(solution_file, 'w') { |f| f << "#{solution_string}" }
