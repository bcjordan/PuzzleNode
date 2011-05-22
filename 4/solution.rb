require 'pp'

w = "remimance"
w1 = "remembrance"
w2 = "reminiscence"

x = "inndietlly"
x1 = "immediately"
x2 = "incidentally"

def longest_sub (word, word2, initial = 0)
#  pp "Trying #{word} and #{word2}, score: #{initial}"
  if word == "" or word2 == ""
    initial
  else
    search = word2.index word[0..0]
    if search
      use = longest_sub(word[1..-1], word2[search+1..-1], initial + 1)
      continue = longest_sub(word[1..-1], word2, initial)
      if use > continue
        use
      else
        continue
      end 
    else
      longest_sub(word[1..-1], word2, initial)
    end
  end
end


words_file = 'INPUT.txt'
solution_file = 'OUTPUT.txt'

solution_string = ""

words = File.read(words_file).split

num_words = words[0].to_i

num_words.times do |i|
  word, word1, word2 = words[i*3+1], words[i*3+2], words[i*3+3]
  word1_score = longest_sub(word, word1)
  word2_score = longest_sub(word, word2)

  if word1_score > word2_score
    pp word1
    solution_string << "#{word1}\n"
  else
    pp word2
    solution_string << "#{word2}\n"
  end
end

open(solution_file, 'w') { |f| f << "#{solution_string}" }

