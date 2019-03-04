def upper_bound(arr, value)
    first = 0
    last = arr.length
    while first < last
        mid = first + (last - first) / 2
        if arr[mid] > value
            last = mid
        else
            first = mid + 1
        end
    end
    first - 1
end

def lower_bound(arr, value)
    first = 0
    last = arr.length
    while first < last
        mid = first + (last - first) / 2
        if arr[mid] < value
            first = mid + 1
        else
            last = mid
        end
    end
    first
end

# https://www.zhihu.com/question/36132386
