class Customer
end
customer = Customer.new

def customer.name
  "Leonard"
end

p customer.name

# 如果你以前没有见过这种语法，你可能会有点困惑，但这其实很明确。上面的代码定义了仅用于customer对象的一个方法，这个特定的方法在其他任何对象上都不能调用。你觉得Ruby是怎么样实现它的呢？事实上，这个方法被称为其实例单例方法。当Ruby执行这一段代码时，它将创建一个单例类，将name方法作为其实例方法，随后将这个匿名类作为`customer`对象的类进行插入。不过即使此时`customer`对象的类是单例类，`Ruby`的内省方法`class`方法仍将跳过它并返回customer。这让我们觉得难以理解，但让Ruby的实现变得简单。当它查找`name`方法时候，遍历类的结构就可以了，不需要特殊的逻辑。
