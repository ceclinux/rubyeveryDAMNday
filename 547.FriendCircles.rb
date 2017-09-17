# @param {Integer[][]} m
# @return {Integer}

def find_circle_num(m)
    elem = Array.new(m.length) {|i| i}
    size = Array.new(m.length, 1)
    0.upto(m.length - 1) do |p|
        (p + 1).upto(m.length - 1) do |q|
            merge(p, q, elem, size) if m[p][q] == 1
            #p elem
        end
    end
    elem.select.with_index {|k, v| k == v}.length
end

private
def merge(p, q, elem, size)
    p = find(p, elem)
    q = find(q, elem)
    sizep = size[p]
    sizeq = size[q]
    if sizep > sizeq
        elem[q] = elem[p]
        size[p] = sizep + sizeq
    else
        elem[p] = elem[q]
        size[q] = sizep + sizeq
    end
end

def find(p, elem)
  while elem[p] != p
      p = elem[p]
  end
  p
end
