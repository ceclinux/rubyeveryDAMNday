# @param {Integer} row_index
# @return {Integer[]}
def get_row(row_index)
    row = [0, 1, 0]
    1.upto(row_index) do |n|
        newrow = [0]
        0.upto(row.length - 2) do |m|
            newrow << (row[m] + row[m + 1])
        end
        newrow << 0
        row = newrow
    end
    row[1...-1]
end
