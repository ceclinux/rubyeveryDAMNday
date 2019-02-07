# @param {String} s
# @return {Integer}
def min_add_to_make_valid(s)
  left_max(s) + right_max(s)
end

def left_max(s)
curr = 0
max = 0
s.chars.each do |t|
  if t == "("
    curr -= 1
  else
    curr += 1
    max = [curr, max].max
  end
end
max
end

def right_max(s)
curr = 0
max = 0
s.reverse.chars.each do |t|
  if t == ")"
    curr -= 1
  else
    curr += 1
    max = [curr, max].max
  end
end
max
end

# @param {Integer[][]} graph
# @return {Integer[][]}
def all_paths_source_target(graph)
  ret = []
  helper(ret, [0] ,graph, graph.length - 1)
  ret
end

def helper(ret, curr, graph, last)
  return if graph.nil? || graph.empty?
  arr = graph[curr.last]
  arr.each do |t|
    if t == last
      ret << (curr + [t])
    else
     helper(ret,curr + [t],  graph, last)
    end
  end
end

def prune_tree(root)
    return nil if root.nil?
    i = prune_tree(root.left)
    j = prune_tree(root.right)
    root.left = i
    root.right = j
    if i.nil? && j.nil? && root.val == 0
      return nil
    end
    return root
end
