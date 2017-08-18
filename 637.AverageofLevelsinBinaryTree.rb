# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {TreeNode} root
# @return {Float[]}
def average_of_levels(root)
    ret = []
    return ret if root.nil?
    current_level = [root]
    while current_level.length != 0
        ret << current_level.map(&:val).reduce {|sum, el| sum + el}.to_f / current_level.length
        next_level = []
        while current_level.length != 0
            node = current_level.shift
            next_level.push node.left unless node.left.nil?
            next_level.push node.right unless node.right.nil?
        end
        current_level = next_level
    end
    ret
end
