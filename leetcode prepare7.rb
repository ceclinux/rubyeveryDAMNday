# @param {Integer[]} nums
# @return {Integer}
def longest_consecutive(nums)
    return 0 if nums.empty?
    sorted_nums = nums.sort
    
    set = Set.new(nums)
    max_con = 1
    nums.each do |s|
        curr_len = 1
        if set.include? s
            set.delete s
            t = s + 1
            while set.include? (t)
                curr_len += 1
                set.delete t
                t += 1
            end

            t = s - 1
            while set.include? (t)
                curr_len += 1
                set.delete t
                t -= 1
            end
            max_con = [curr_len, max_con].max
        end
    end
    max_con
end

# @param {Integer[]} candidates
# @param {Integer} target
# @return {Integer[][]}
# @param {Integer[]} nums
# @param {Integer} target
# @return {Integer}
def combination_sum(nums, target)
    curr_comb = []
    combs = []
    comb_helper(nums, target, curr_comb, combs)
    combs
end

def comb_helper(nums, target, curr_comb, combs)
    if target < 0
        return
    end
    
    if target == 0
        combs << curr_comb.clone
        return
    end
    
    nums.each_with_index do |t, i|
        curr_comb << t
        comb_helper(nums[i..-1], target - t, curr_comb, combs)
        curr_comb.pop
    end
end
