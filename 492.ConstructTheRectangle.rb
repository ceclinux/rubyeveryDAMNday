# @param {Integer} area
# @return {Integer[]}
def construct_rectangle(area)
    a = 1
    sqrt = Math.sqrt(area).to_i
    ret = [area, 1]
    while a <= sqrt
        if area % a == 0
            ret = [area / a, a]
        end
        a += 1
    end
    ret
end
