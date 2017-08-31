# @param {Integer[]} a
# @return {Integer}
def number_of_arithmetic_slices(a)
    ret = 0
    if a.length < 3
        return ret
    end
    diff = a[1] - a[0]
    len = 1
    2.upto(a.length -  1) do |n|
        if diff == a[n] - a[n - 1]
            ret += len
            len += 1
        else
            diff = a[n] - a[n - 1]
            len = 1
        end
    end
        ret
end
