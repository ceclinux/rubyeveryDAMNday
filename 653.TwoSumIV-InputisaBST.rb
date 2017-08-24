# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {TreeNode} root
# @param {Integer} k
# @return {Boolean}
def find_target(root, k)
    s = Set.new
    stack = []
    node = root
    while !node.nil? || !stack.empty?
        if !node.nil?
            stack << node
            if s.include? k - node.val
                return true
            end
            s << node.val
            node = node.left
        else
            node = stack.pop
            node = node.right
        end
    end
    false
end
