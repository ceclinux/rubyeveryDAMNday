# Definition for singly-linked list.
# class ListNode
#     attr_accessor :val, :next
#     def initialize(val)
#         @val = val
#         @next = nil
#     end
# end

# @param {ListNode} l1
# @param {ListNode} l2
# @return {ListNode}
def add_two_numbers(l1, l2)
    carry = 0
    dummy = ListNode.new(0)
    start = dummy
    while l1 != nil && l2 != nil
        sum = l1.val + l2.val + carry
        val = sum % 10
        carry = sum / 10
        start.next = ListNode.new(val)
        start = start.next
        l1 = l1.next
        l2 = l2.next
    end
    while l1!= nil
        sum = l1.val+ carry
        val = sum % 10
        carry = sum / 10
        start.next = ListNode.new(val)
        start = start.next
        l1 = l1.next
    end
    while l2!= nil
        sum = l2.val+ carry
        val = sum % 10
        val = sum % 10
        carry = sum / 10
        start.next = ListNode.new(val)
        start = start.next
        l2 = l2.next
    end
    if carry == 1
        start.next = ListNode.new(1)
    end
    dummy.next
end
