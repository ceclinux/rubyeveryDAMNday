# @param {String[]} paths
# @return {String[][]}
def find_duplicate(paths)
    split_values = paths.map(&:split).map {|t| [t.first].product(t[1...t.length])}.flatten(1)
    group_values = split_values.group_by {|v| /\(.*\)/.match(v[1]).to_s}
    group_values.map {|k,v| v.map{|t| t[0] + '/' + t[1][0...t[1].index('(')]}}.select {|t| t.length > 1}
end
