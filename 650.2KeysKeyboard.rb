# @param {Integer} n
# @return {Integer}
def min_steps(n)
    d = 0
    2.upto(n) do |t|
        while n % t == 0
            d += t
            n /= t
        end
    end
    d
end
