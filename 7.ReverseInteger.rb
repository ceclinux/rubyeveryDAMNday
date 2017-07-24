# @param {Integer} x
# @return {Integer}
def reverse(x)
    flag = 1
    if x < 0
        flag = -1
        x = -x
    end
    ret = 0
    while x > 0
        temp = x % 10 
        ret = (ret * 10) + temp
        x = x / 10
    end
    ret = ret * flag
    if ret > ((1 << 31) - 1) || ret < - (1 << 31)
        return 0
    end
    ret
end
