def two_sum(nums, target)
    h = {}
    nums.each_with_index do |i, index|
        return [h[target - i], index] if h[target - i] != nil
        h[i] = index
    end
    [-1, -1]
end

p two_sum([1,2,4,6,3], 5)
p two_sum([1,2,4,6,3], 6)
p two_sum([1,2,4,6,3], 10)


