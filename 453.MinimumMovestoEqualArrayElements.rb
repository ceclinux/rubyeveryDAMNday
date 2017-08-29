# @param {Integer[]} nums
# @return {Integer}
def min_moves(nums)
    total = 0
    min = nums[0]
    nums.each do |n|
        total += n
        min = [min, n].min
    end
    total - (min * nums.length)
end
