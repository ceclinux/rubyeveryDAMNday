# @param {Integer[]} nums
# @return {Integer}
def array_nesting(nums)
    bitArray = Array.new(nums.length, false)
    max = 1
    curr = 0
    0.upto(nums.length - 1) do |i|
        var = nums[i]
        t = i
        while !bitArray[t] && var != t
            bitArray[t] = true
            curr += 1
            max = [max, curr].max
            t = var
            var = nums[var]
            
        end
        curr = 0
    end
    max
end
