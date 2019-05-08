# @param {Integer[]} nums
# @param {Integer} target
# @return {Integer[]}
def search_range(nums, target)
    ret = []
    firs = 0
    las = nums.size - 1
    
    while firs <= las
        mid = (firs + las) / 2
        if nums[mid] < target
            firs = mid + 1
        else
            las = mid - 1
        end
    end
    if nums[las + 1] == target
        ret << (las + 1)
    else
        ret << -1
    end
    
    firs = 0
    las = nums.size - 1
    
    while firs <= las
        mid = (firs + las) / 2
        if nums[mid] <= target
            firs = mid + 1
        else
            las = mid - 1
        end
    end
    if nums[firs - 1] == target
        ret << (firs - 1)
    else
        ret << -1
    end
    ret
end

# @param {Integer[]} nums
# @param {Integer} target
# @return {Integer}
def search(nums, target)
    low = 0
    high = nums.length - 1
    
    while low <= high
        mid = (low + high) / 2
        if nums[mid] < target
            low = mid + 1
        elsif nums[mid] > target
            high = mid - 1
        else
            return mid
        end
    end
    -1
end
