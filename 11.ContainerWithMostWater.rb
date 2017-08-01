# @param {Integer[]} height
# @return {Integer}
def max_area(height)
    head = 0
    tail = height.length - 1
    currtail =  tail
    currhead = head
    max = [height[head], height[tail]].min * (tail - head)
    while head < tail
        if height[head] < height[tail]
            while currhead < currtail and  height[head] >= height[currhead]
                currhead = currhead + 1
            
            end
            head = currhead
            
        else
            while currhead < currtail and height[tail] >= height[currtail]
                currtail = currtail - 1
                
            end
            tail = currtail
        end
        max =  [[height[head], height[tail]].min * (tail - head), max].max
    end
    max
end
