# @param {String} s
# @return {Integer}
def length_of_last_word(s)
    len = s.length
    while len > 0 and s[len - 1] == ' '
        len = len - 1
    end
    # p len
    endchar = len
    while len > 0 and s[len - 1] != ' '
        len = len - 1
    end
    # p len

    endchar - len
        
end
