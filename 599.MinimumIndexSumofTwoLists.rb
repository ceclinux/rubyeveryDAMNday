# @param {String[]} list1
# @param {String[]} list2
# @return {String[]}
def find_restaurant(list1, list2)
    h1 = Hash.new
    list1.each_with_index do |elem, index|
      h1[elem] = [index] if h1[elem].nil?
    end
    list2.each_with_index do |elem, index|
      h1[elem] << index if h1[elem]&.length == 1
    end
    v1 = h1.select {|key, value| value.length == 2}
    min = v1.first[1].reduce(:+)
    v1.each do |k,v|
        v1[k] = v.reduce(:+)
        min = [v1[k], min].min
    end
    #p min
    v1.select {|k,v| v == min}.keys
end
