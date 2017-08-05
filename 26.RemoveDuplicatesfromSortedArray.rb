# @param {Integer[]} nums
# @return {Integer}
def remove_duplicates(nums)
    tail = 0
    0.upto(nums.length - 1) do |index|
        if index == 0 or nums[index] != nums[index - 1]
            nums[tail] = nums[index]
            tail = tail + 1
        end
    end
    tail
end
    
