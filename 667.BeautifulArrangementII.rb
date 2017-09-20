# @param {Integer} n
# @param {Integer} k
# @return {Integer[]}
def construct_array(n, k)
    if k % 2 == 1
        start = k / 2 + 1
        flag = 1
    else
        start = n - (k / 2)
        flag = -1
    end
    ret = [start]
    state = 1
    1.upto(k) do |i|
        ret << (ret[-1] + state * i)
        state *= -1
    end
    state = if ret[-1] > start
              1
            else
              -1
            end
    1.upto(n - k - 1) do |i|
        ret << (ret[-1] + state)
    end
    ret
end
