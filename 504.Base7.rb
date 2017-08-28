# @param {Integer} num
# @return {String}
def convert_to_base7(num)
    return "0" if num.zero?
        
    ret = ""
    flag = 1
    if num < 0
        flag = -1
        num = -num
    end
    while num > 0
        ret = (num % 7).to_s + ret
        num = num / 7
    end
    flag < 0 ? "-" + ret: ret
end
