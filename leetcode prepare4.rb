# @param {String} s
# @return {Integer[]}
def partition_labels(s)
  h = {}
  s.chars.each_with_index do |c, i|
    if h[c]
      h[c] << i
    else
      h[c] = [i]
    end
  end
  sorted = h.values.sort_by {|t| t[0]}
  # p sorted
  ret = []
  while sorted.size > 1
    first = sorted.shift
    if first.last > sorted.first.first
      sorted[0] = [first.first, [first.last, sorted.first.last].max]
    else
      ret << (first.last - first.first + 1)
    end
  end
  if sorted.size == 1
    ret << (sorted.first.last - sorted.first.first + 1)
  end
  ret
end

# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {Integer} n
# @return {TreeNode[]}
def all_possible_fbt(n)
  if n % 2 == 0
    return []
  end
  if n == 1
    return [TreeNode.new(0)]
  end
  n = n - 1
  ret = []
  1.upto(n - 1) do |t|
    left = all_possible_fbt(t)
    right = all_possible_fbt(n - t)
    left.each do |i|
      right.each do |j|
        root = TreeNode.new(0)
        root.left = i
        root.right = j
        ret << root
      end
    end
  end
  ret
end



def matrix_score(a)
  a.each_with_index do |t, i|

    if t[0] == 0
      a[i] = flip_row(t)
    end
  end
  p a
  1.upto(a[0].length - 1) do |t|
    numbers = a.map {|s| s[t]}
    flip_col(a, t) if (numbers.count {|t| t==0} > numbers.count {|t| t==1})
  end
  calculate_score(a)
end

def calculate_score(a)
  score = 0
  a.each do |t|
    score << t.length
    bin_str = "0b" + t.join()
    score += Integer(bin_str)
  end
  score
end

def flip_row(arr)
  arr.map do |t|
    if t == 1
      0
    else
      1
    end
  end
end

def flip_col(a, i)
  a.each do |t|
    if t[i] == 1
      t[i] = 0
    else
      t[i] = 1
    end 
  end
end
