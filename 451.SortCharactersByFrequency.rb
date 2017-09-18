# @param {String} s
# @return {String}
def frequency_sort(s)
    return s  if s.empty?
    s.each_char.group_by(&:itself).sort_by {|k,v| v.length}.map {|k,v| v.reduce(:+)}.reduce(:+).reverse
end
