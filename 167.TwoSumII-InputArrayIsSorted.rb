# @param {Integer[]} numbers
# @param {Integer} target
# @return {Integer[]}
def two_sum(numbers, target)
    head = 0
    tail = numbers.length - 1
    while head < tail
        sum = numbers[head] + numbers[tail]
        if sum < target
            head += 1
        elsif sum > target
            tail -= 1
        else
            return [head + 1, tail + 1]
        end
    end
    return [0, 0]
end
