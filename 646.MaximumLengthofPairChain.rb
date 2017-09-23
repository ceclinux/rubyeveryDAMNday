# @param {Integer[][]} pairs
# @return {Integer}
def find_longest_chain(pairs)
    pairs.sort! { |x,y| x[0] <=> y[0] }
    #p pairs
    val = -9999999999
    count = 0
    index = 0
    while index < pairs.length
        index = pairs.bsearch_index {|x| x[0] > val}
        #p index
        return count if index.nil?
        val =  pairs[index..-1].min_by {|v| v[1]}[1]
        #p val
        count += 1
    end
end
