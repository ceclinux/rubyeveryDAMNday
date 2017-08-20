# @param {String} s
# @return {Integer}
def longest_palindrome(s)
    array = Array.new(52, 0)
    s.chars.each do |c|
        if c.ord >= 'a'.ord && c.ord <= 'z'.ord
            array[c.ord - 'a'.ord] += 1
        else
            array[c.ord - 'A'.ord] += 1
        end
    end
    flag = 0
    total = 0
    array.each do |a|
        if a % 2 == 1
            flag = 1
        end
        total += (a / 2) * 2
    end
    if flag == 1
        total += 1
    end
    total
end
