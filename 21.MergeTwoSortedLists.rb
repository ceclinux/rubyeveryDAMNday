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
def merge_two_lists(l1, l2)
    dummy = ListNode.new(-1)
    dummyhead = dummy
    while l1 != nil and l2 != nil
        if l1.val < l2.val
            dummyhead.next = l1
            l1 = l1.next
        else
            dummyhead.next = l2
            l2 = l2.next
        end
        dummyhead = dummyhead.next
    end
    while l1 != nil
        dummyhead.next = l1
        dummyhead = dummyhead.next
        l1 = l1.next
    end
    while l2 != nil
        dummyhead.next = l2
        dummyhead = dummyhead.next
        l2 = l2.next
    end
    dummy.next
end
