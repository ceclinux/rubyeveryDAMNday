# @param {Integer[]} nums
# @return {Integer}
def max_sub_array(nums)
    min = 0
    final = nums[0]
    curr = 0
    nums.each_with_index do |a, index|        
        curr += a        
        final = [curr - min, final].max if index != 0
        min = [curr, min].min
    end
    final
end
