# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {TreeNode} t1
# @param {TreeNode} t2
# @return {TreeNode}
def merge_trees(t1, t2)
    head = nil
    if t1.nil? && t2.nil?
        return
    end
    if t1.nil?
        head = TreeNode.new t2.val
        head.left = merge_trees(t2.left, nil)
        head.right = merge_trees(t2.right, nil)
    elsif t2.nil?
        head = TreeNode.new t1.val 
        head.left = merge_trees(t1.left, nil)
        head.right = merge_trees(t1.right, nil)
    else !t1.nil? && !t2.nil?
        head = TreeNode.new t1.val + t2.val
        head.left = merge_trees(t1.left, t2.left)
        head.right = merge_trees(t1.right, t2.right) 
    end
    return head
end
