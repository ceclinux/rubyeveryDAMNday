# @param {String} num1
# @param {String} num2
# @return {String}
def add_strings(num1, num2)
    if num1.length < num2.length
        return add_strings(num2, num1)
    end
    carry = 0
    ret = ""
    1.upto(num2.length) do |i|
        total = num1[-i].to_i + num2[-i].to_i + carry
        if total >= 10
            carry = 1
        else
            carry = 0
        end
        ret = (total % 10).to_s + ret
    end
    (num2.length + 1).upto(num1.length) do |i|
        total = num1[-i].to_i + carry
        if total >= 10
            carry = 1
        else
            carry = 0
        end
        ret = (total % 10).to_s + ret
    end
    if carry == 1
        ret = "1" + ret
    end
    return ret == "" ? "0": ret
end
