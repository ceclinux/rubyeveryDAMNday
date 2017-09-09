# @param {Integer} m
# @param {Integer} n
# @param {Integer[][]} ops
# @return {Integer}
def max_count(m, n, ops)
    maxx = m
    maxy = n
    ops.each do |op|
        maxx = [op[0], maxx].min
        maxy = [op[1], maxy].min
    end
    maxx * maxy
end
