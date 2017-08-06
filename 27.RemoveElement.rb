# @param {Integer[]} nums
# @param {Integer} val
# @return {Integer}
def remove_element(nums, val)
    tail = 0
    0.upto(nums.length - 1) do |index|
        if nums[index] != val
            nums[tail] = nums[index]
            tail += 1
        end
    end
    tail
end
