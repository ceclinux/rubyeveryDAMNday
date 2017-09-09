# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {TreeNode} root
# @return {TreeNode}
def convert_bst(root)
    total = 0
    if root.nil?
        return
    end
    node = root
    stack = []
    while !node.nil? || !stack.empty?
        if !node.nil?
            stack << node
            node = node.left
        else
            node = stack.pop
            total += node.val
            node = node.right
        end
    end
    node = root
    stack = []
    while !node.nil? || !stack.empty?
        if !node.nil?
            stack << node
            node = node.left
        else
            node = stack.pop
            temp = node.val
            node.val = total
            total -= temp
            node = node.right
        end
    end
    return root
end
