# @param {String} s
# @return {Integer}

# require 'Set'
def length_of_longest_substring(s)
    substr_arr = []
    max_length = 0
    
    s.chars.each do |char|
    	substr_index = substr_arr.index(char)
    	substr_arr = substr_arr[(substr_index + 1)..-1] if substr_index
    	substr_arr << char
    	max_length += 1 if substr_arr.length > max_length
    end
    
    max_length
end
