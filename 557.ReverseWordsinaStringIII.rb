# @param {String} s
# @return {String}
def reverse_words(s)
    head = 0
    tail = 0
    while head < s.length
        while head < s.length && s[head] != ' '
            head += 1
        end
        head -= 1
        if(s[tail] == ' ')
            tail += 1
        end
        swap_word(head, tail, s)
        head += 2
        tail = head
    end
    s
end
        
private 
def swap_word(head, tail, s)
    while tail < head
        s[head], s[tail] = s[tail], s[head]
        head -= 1
        tail += 1
    end
end
