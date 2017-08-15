# @param {Integer[]} g
# @param {Integer[]} s
# @return {Integer}
def find_content_children(g, s)
    g.sort!
    s.sort!
    gtail, stail = 0, 0
    while gtail < g.length && stail < s.length
        if g[gtail] <= s[stail]
            gtail += 1
            stail += 1
        else
            stail += 1
        end
    end
    gtail
end
