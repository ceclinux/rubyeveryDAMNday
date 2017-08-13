# @param {String} s
# @param {String} p
# @return {Integer[]}
def find_anagrams(s, p)
    sdict = Array.new(26, 0)
    pdict = Array.new(26, 0)
    ret = Array.new
    if s.length < p.length
        return ret
    end
    0.upto(p.length - 1) do |i|
        sdict[s[i].ord - 'a'.ord] += 1
    end
    0.upto(p.length - 1) do |i|
        pdict[p[i].ord - 'a'.ord] += 1
    end

    if sdict == pdict
        ret << 0
    end
    0.upto(s.length - p.length - 1) do |i|
        sdict[s[i].ord - 'a'.ord] -= 1
        sdict[s[i + p.length].ord - 'a'.ord] += 1
        if sdict == pdict
            ret << i + 1
        end
    end
    ret
end
