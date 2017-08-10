# @param {Integer[]} nums
# @return {Integer[]}
def find_disappeared_numbers(nums)
    0.upto(nums.length - 1) do |i|
        while nums[i] != i + 1 and nums[i] != nums[nums[i] - 1]
            nums[nums[i] - 1], nums[i] = nums[i], nums[nums[i] - 1]
        end
    end
    ret = []
    0.upto(nums.length - 1) do |i|
        if nums[i] != i + 1
            ret << i + 1
        end
    end
    ret
end
