# @param {Integer[][]} grid
# @return {Integer}
def island_perimeter(grid)
    total = 0
     0.upto(grid.length - 1) do |i|
        0.upto(grid[0].length - 1) do |j|
            if grid[i][j] == 1
                total += 4
                total -= 2 if i != 0 && grid[i - 1][j]  == 1
                total -= 2 if j != 0 && grid[i][j - 1] == 1
            end
        end
     end
    total
end
