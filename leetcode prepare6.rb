# @param {Integer[]} a
# @return {Integer[]}
def pancake_sort(a)
    return [] if a.size == 0
    max = a[0]
    max_index = 0
    a.each_with_index do |t,i|
        if t > max
            max = t
            max_index = i
        end
    end
    psort(max_index, a)
    psort(a.length - 1, a)
    [max_index + 1, a.size] + pancake_sort(a[0...-1])
        
end


def psort(n, arr)
    first = 0
    last = n
    while first < last
        tmp = arr[first]
        arr[first] = arr[last]
        arr[last] = tmp
        first += 1
        last -= 1
    end
    arr
end
