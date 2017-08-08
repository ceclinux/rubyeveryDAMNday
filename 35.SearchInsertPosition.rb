# @param {Integer[]} nums
# @param {Integer} target
# @return {Integer}
def search_insert(nums, target)
    head = 0
    tail = nums.length - 1
    while head <= tail
        mid = head + (tail - head ) / 2
        if nums[mid] == target
            return mid
        elsif nums[mid] > target
            tail = mid - 1
        else
            head = mid + 1
        end
    end
    head
end