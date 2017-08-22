# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {TreeNode} t
# @return {String}
def tree2str(t)
        return "" if t.nil?;
        
        String result = t.val.to_s + "";
        
        left = tree2str(t.left);
        right = tree2str(t.right);
        
        return result if (left == "" && right == "")
        return result + "()" + "(" + right + ")"if left == ""
        return result + "(" + left + ")" if right == ""
        return result + "(" + left + ")" + "(" + right + ")"
end
