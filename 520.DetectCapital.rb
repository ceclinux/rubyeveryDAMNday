# @param {String} word
# @return {Boolean}
def detect_capital_use(word)
    cs = word.chars
    cs.all? {|e| e == e.upcase} || cs.all? {|e| e == e.downcase} || (word[0] == word[0].upcase && word[1..-1].chars.all? {|e| e == e.downcase})
end
