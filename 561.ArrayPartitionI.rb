# @param {Integer[]} nums
# @return {Integer}
def array_pair_sum(nums)
    nums.sort().select.each_with_index { |_, i| i.even? }.inject(0){|sum,x| sum + x }
end
