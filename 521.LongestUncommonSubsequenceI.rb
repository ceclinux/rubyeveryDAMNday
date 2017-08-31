# @param {String} a
# @param {String} b
# @return {Integer}
def find_lu_slength(a, b)
    return [a.length, b.length].max if a !=b
    -1
end
