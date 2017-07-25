# @param {String} s
# @param {Integer} num_rows
# @return {String}
def convert(s, num_rows)
  return s.dup if num_rows == 1 || s.size <= num_rows

  newstr, cycle = '', 2 * num_rows - 2
  0.upto(num_rows - 1) do |row|
    0.upto(s.size.fdiv(cycle).ceil - 1) do |kth|
      base = kth * cycle

      newstr << s[base + row].to_s
      newstr << s[base + cycle - row].to_s if row.between?(1, num_rows - 2)
    end
  end
  newstr
end
