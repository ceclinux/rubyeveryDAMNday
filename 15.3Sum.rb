# @param {Integer[]} nums
# @return {Integer[][]}
def three_sum(nums)
    return_set = []
    if nums.length < 3
        return_set
    end
    sort_arr = nums.sort
    first = 0
    while first < nums.length - 2
        curr = sort_arr[first]
        head = first + 1
        tail = nums.length - 1
        while head < tail and ((first > 0 && sort_arr[first] != sort_arr[first - 1]) or first == 0)
                sum = sort_arr[head] + sort_arr[tail] + curr
                if sum < 0
                    head = head + 1
                elsif sum > 0
                    tail = tail - 1
                else
                    return_set.push([curr, sort_arr[head], sort_arr[tail]])
                    while sort_arr[head] == sort_arr[head + 1] and head < tail
                        head = head + 1
                    end
                    while sort_arr[tail] == sort_arr[tail - 1] and head < tail
                        tail = tail  - 1
                    end
                    head = head + 1
                    tail = tail - 1
                end
        end
        first = first + 1
    end
    return_set
end
