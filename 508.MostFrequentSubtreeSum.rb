# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {TreeNode} root
# @return {Integer[]}

def find_frequent_tree_sum(root)
    arr, sum=helper(root)
    freq = arr.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    freqvalue = freq.values.max
    freq.select{|k, v| v == freqvalue }.map{|k,v| k}
end

private
def helper(root)
    return [[], 0]if root.nil?
    arrleft, leftsum = helper(root.left)
    arrright, rightsum = helper(root.right)
    ret = arrleft + arrright << (leftsum + rightsum + root.val)
    [ret, (leftsum + rightsum + root.val)]
end
