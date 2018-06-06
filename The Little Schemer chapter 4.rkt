#lang racket

(define add1
  (lambda (n)
    (+ n 1)))

(add1 67)

(define sub1
  (lambda (n)
    (- n 1)))

(sub1 5)

(zero? 0)

(zero? 1492)

(+ 46 12)

(define add
  (lambda (x y)
    (cond
      ((zero? y) x)
      (else (add1 (add x (sub1 y)))))))

(add 66 88)

;但这样的话，不是违反了Scheme十诫之第一诫了吗？
;是的，但我们可以把zero?当成null?对待，因为zero?询问数字是否为空，null?则询问列表是否为空。

;如果zero?就像null?这样，那么add1就像cons吗？ 十的，cons构建列表，add1则构建数字

(- 14 3)

(define sub
  (lambda (n m)
    (cond
      ((zero? m) n)
      (else (sub1 (sub n (sub1 m)))))))

(sub 12 5)

;当对一个原子列表lat进行递归调用时，询问两个有关lat的问题：（null? lat)和else
;当对一个数字n进行递归调用时，询问两个有关n的问题(zero? n)和else

(define addtup
  (lambda (tup)
    (cond
      ((null? tup) 0)
      (else (add (car tup) (addtup (cdr tup)))))))

(addtup '(3 5 2 4))

;在递归时总是改变至少一个参数，该参数必须向着不断接近结束条件而改变。改变的参数必须在结束条件中得以测试；当使用cdr时，用null?测试是否结束；当使用sub1时，用zero?测试是否结束

(define mul
  (lambda (n m)
    (cond
      ((zero? m) 0)
      (else (+ n (mul n (sub1 m)))))))

(mul 13 4)
(mul 5 3)

;为什么*函数的结束条件代码行的值是0？因为0对+不产生影响也即 N + 0 = N

;当用+构建一个值时，总是使用0作为结束代码行的值，因为加上0不会改变加法的值
;当用*构建一个值时，总是使用1作为结束代码行的值，因为乘以1不会改变乘法的值
;当用cons构建一个值时，总是考虑()作为结束代码行的值

(define tup+
  (lambda (tup1 tup2)
    (cond
      ((null? tup1) '())
      (else (cons (+ (car tup1) (car tup2)) (tup+ (cdr tup1) (cdr tup2)))))))

(tup+ '(2 3) '(4 6))
(tup+ '(3 6 9 11 4) '(8 5 2 0 7))
