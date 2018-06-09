# Prevents further modifications to obj. A RuntimeError will be raised if modification is attempted. There is no way to unfreeze a frozen object. See also Object#frozen?.
# This method returns self.
devices = {
  tv: 'Samsung',
  phones: ['iPhone', 'Samsung']
}.freeze

a = 1
p a.frozen?
a = 2

devices[:tv] << ' and LG'
devices[:phones].delete ('Samsung')

# Objects of the following classes are always frozen: Integer, Float, Symbol.

p 1.frozen?

t = {a: 'a', b: 'b', c: 'c'}
o = t.dup
p o.frozen?

q = ["test", "joh"].freeze
q.freeze
q[0] << "test"
p q
q = ['john'].freeze
p q
q[0] << "wawa"
p q
module Defaults
  TIMEOUT = 5
end

Defaults.freeze

Defaults::TIMEOUT = 6
# 报错
q[0] = 'fack'
