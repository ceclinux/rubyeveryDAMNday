def find_words(words)
    rows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'].map {|s| s.chars}
    ret = []
    words.each do |val|
        valmod = val.downcase.chars.uniq
        if rows.any? {|s| (valmod - s).empty?}
            ret << val
        end
    end
    ret
            
end
