class MinStack

=begin
    initialize your data structure here.
=end
    def initialize()
        @min = nil
        @stack = []
    end


=begin
    :type x: Integer
    :rtype: Void
=end
    def push(x)
        if @stack.length == 0 or x <= @min
            @stack.push @min
            @min = x
        end
        @stack.push x
            
    end


=begin
    :rtype: Void
=end
    def pop()
        ret = @stack.pop()
        if ret == @min
            @min = @stack.pop()
        end
        ret
    end


=begin
    :rtype: Integer
=end
    def top()
        @stack.last
    end


=begin
    :rtype: Integer
=end
    def get_min()
       @min 
    end


end
