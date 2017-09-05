def top_k_frequent(nums, k)
     nums.group_by(&:itself).sort_by {|_,s| -s.length}.first(k).map(&:first)
end
