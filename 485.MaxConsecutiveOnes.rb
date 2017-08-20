# @param {Integer[]} nums
# @return {Integer}
def find_max_consecutive_ones(nums)
    curr = 0
    max =  0
    nums.each do |n|

        if n == 1
            curr += 1
        else
            curr = 0
        end

        max = curr if curr > max
    end
    max
end
