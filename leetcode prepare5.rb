# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {TreeNode} root
# @return {Integer}

def distribute_coins(root)
  return 0 if root.nil?
  total = [0]
  preorder(root, total)
  total[0]
end

def preorder(root, total)
  if root.nil? 
    return 0
  end
 left =  preorder(root.left, total) 
  right =  preorder(root.right, total)
  total[0]  += (left.abs + right.abs)
  return left + right + root.val - 1
end

# @param {Character[][]} board
# @return {Integer}
def count_battleships(board)
  total  = 0
  board.each_with_index do |i, x|
    i.each_with_index do |j, y|
      if board[x][y] == 'X'
        total += 1
        if (x > 0 && board[x - 1][y] == 'X') || (y > 0 && board[x][y - 1] == 'X')
          total -= 1
        end
      end
    end
  end
  total
end

# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {TreeNode} root1
# @param {TreeNode} root2
# @return {Boolean}
def flip_equiv(root1, root2)
  return true if root1.nil? && root2.nil?
  return false if root1.nil? || root2.nil? || root1.val != root2.val
  return ((flip_equiv(root1.left, root2.right) &&  flip_equiv(root1.right, root2.left)) ||
   ( flip_equiv(root1.left, root2.left) && flip_equiv(root1.right, root2.right)))

end
