def max_increase_keeping_skyline(grid)
  return 0 if grid.length == 0
  row_max_arr = grid.map {|t| t.max}
  col_max_arr = (0...grid[0].size).map do |t|
    (grid.map {|s| s[t]}).max
  end
  
  total = 0
  grid.each_with_index do |s, x|
    s.each_with_index do |t, y|
      curr_max = [row_max_arr[x], col_max_arr[y]].min
      total += (curr_max - t)
    end
  end
  
  total
end  

pp max_increase_keeping_skyline([ [3, 0, 8, 4], 
[2, 4, 5, 7],
[9, 2, 6, 3],
[0, 3, 1, 0] ])

def range_sum_bst(root, l, r)
    helper( root, l, r)
end

def helper(root, l, r)
  if root.nil?
    return 0
  end
  p = 
  if root.val > l
 helper(root.left, l, r)
  else
    0
  end
s = if root.val <= r && root.val >= l
  root.val
else 
  0
end
q = if root.val < r
   helper(root.right, l, r)
else
  0
end
p + q + s
end 


def insert_into_bst(root, val)
    if root.nil?
      return TreeNode.new(val)
    end
    if val < root.val
      if root.left.nil?
        root.left = TreeNode.new(val)
      else
        insert_into_bst(root.left, val)
      end
    else
      if root.right.nil?
        root.right = TreeNode.new(val)
      else
        insert_into_bst(root.right, val)
      end
    end
   root
end

