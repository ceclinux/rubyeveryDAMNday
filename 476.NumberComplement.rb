# @param {Integer} num
# @return {Integer}
def find_complement(num)
    total = 1
    temp = num
    while temp > 0
        temp >>= 1
        total <<= 1
    end
    total - num - 1
end
