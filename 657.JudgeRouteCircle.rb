# @param {String} moves
# @return {Boolean}
def judge_circle(moves)
    upcount = 0
    rightcount = 0
    moves.each_char do |m|
        case m
        when 'U'
            upcount += 1
        when 'D'
            upcount -= 1
        when 'R'
            rightcount += 1
        when 'L'
            rightcount -= 1
        end
    end
    upcount.zero? && rightcount.zero?
end
