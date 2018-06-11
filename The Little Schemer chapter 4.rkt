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
      ((and (null? tup1) (null? tup2)) '())
      ((null? tup1) tup2)
      ((null? tup2) tup1)
      (else
       (cons (+ (car tup1)(car tup2))
             (tup+
              (cdr tup1) (cdr tup2)))))))

(tup+ '(3 7 8 1) '(4 6))

(define tup2+
  (lambda (tup1 tup2)
    (cond
      ((null? tup1) tup2)
      ((null? tup2) tup1)
      (else
       (cons (+ (car tup1) (car tup2))
             (tup+ (cdr tup1) (cdr tup2)))))))

(tup2+ '(3 7 8 1) '(4 6))

(define lessThan
  (lambda (x y)
    (cond
      ((and (eq? x 0) (eq? y 0)) #f)
      ((eq? x 0) #t)
      ((eq? y 0) #f)
      (else (lessThan (sub1 x) (sub1 y))))))

(lessThan 4 6)

(lessThan 2 2)

(lessThan 3 2)

(define lessThan2
  (lambda (x y)
    (cond
    ((zero? y) #f)
    ((zero? x) #t)
    (else (lessThan2 (sub1 x) (sub1 y))))))

(define equal
  (lambda (x y)
    (cond
    ((and (zero? x) (zero? y)) #t)
    ((or (zero? x) (zero? y)) #f)
    (else (equal (sub1 x) )(sub1 y)))))

(equal? 2 3)

(equal? 10 10)

(define equal2
  (lambda (n m)
    (cond
      ((zero? m) (zero? n))
      ((zero? n) #f)
      (else (equal2 (sub1 n) (sub1 m))))))

(define equal3
  (lambda (n m)
    (cond
      ((> n m) #f)
      ((< n m) #f)
      (else #t))))

(define up
  (lambda (n m)
    (cond
      ((zero? m) 1)
      (else (* n (up  n (sub1 m)))))))

(up 2 3)

(define divide
  (lambda (n m)
    (cond
      ((< n m) 0)
      (else (add1 (divide (- n m ) m))))))

(define length
  (lambda (lat)
    (cond
      ((null? lat) 0)
      (else (add1 (length (cdr lat)))))))

(define pick
  (lambda (n lat)
    (cond
      ((eq? 1 n) (car lat))
      (else (pick (sub1 n) (cdr lat))))))

(pick 4 '(lasagna spaghetti ravioli macaroni meatball))

(define rempick
  (lambda (n  lat)
    (cond
      ((zero? (sub1 n)) (cdr lat))
      (else (cons (car lat) (rempick (sub1 n) (cdr lat)))))))

(rempick 3 '(hotdogs with hot mustard))

(define no-nums
  (lambda (lat)
    (cond
      ((null? lat) '())
      ((number? (car lat)) (no-nums (cdr lat)))
      (else (cons (car lat) (no-nums (cdr lat)))))))

(no-nums '(5 pears 6 prunes 9 dates))

(define all-nums
  (lambda (lat)
    (cond
      ((null? lat) '())
      ((number? (car lat)) (cons (car lat) (all-nums (cdr lat))))
      (else (all-nums (cdr lat))))))

(all-nums '(5 pears 6 prunes 9 dates))

(define eqan?
  (lambda (x y)
    (cond
      ((and (number? x) (number? y)) (= x y))
      ((or (number? x) (number? y)) #f)
      (else (eq? x y)))))

(define occur
  (lambda (a lat)
    (cond
      ((null? lat) 0)
      ((eq? a (car lat)) (add1 (occur a (cdr lat))))
      (else  (occur a (cdr lat))))))

(define one?
  (lambda n
      (= 1 n)))

(define rempick2
  (lambda (n lat)
    (cond
      ((one? n) (cdr lat))
      (else (cons (car lat) (rempick2 (sub1 n) (cdr lat)))))))

(rempick 2 '(hotdogs with hot mustard))
                
