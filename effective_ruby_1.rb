class SillyBase
  def m1(m1 = 2, m2 = 3)
    m1 + m2
  end
end
class SuperSilliness < SillyBase
  def m1(x, y)
    p super(1, 2) # call with 1, 2
    p super(x, y) # call with x, y
    p super x, y  # same as above
    p super #same as above
    p super()
  end
end

SuperSilliness.new.m1(4,5)
