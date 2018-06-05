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
      (else (add (add1 x) (sub1 y))))))

(add 66 88)
