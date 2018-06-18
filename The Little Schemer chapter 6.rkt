#lang racket

;一个算术表达式要么是一个原子（包括数字），要么是用+、x或者^连接起来的两个算术表达式

(define atom?
  (lambda (x)
    (and (not (pair? x)) (not (null? x)))))
(atom? 't)
(pair? '(22 + 3 x 5))
(atom? '(22 + 3 x 5))
(define numbered?
  (lambda (x)
    (cond
      ((atom? x) (number? x))
      ((eq? (car (cdr x)) '+)
       (and (numbered? (car x)) (numbered? (car (cdr (cdr x))))))
      ((eq? (car (cdr x)) '-)
       (and (numbered? (car x)) (numbered? (car (cdr (cdr x))))))
      ((eq? (car (cdr x)) '^)
       (and (numbered? (car x)) (numbered? (car (cdr (cdr x))))))
      (else #f)
      )))

(numbered? '2)
(numbered? '(2 + 3 ^ 5))
      
(numbered? '(22 + (3 * 5)))

(define value
  (lambda (x)
    (cond
      ((atom? x) x)
       ((eq? (car (cdr x)) '+)
       (+ (value (car x)) (value (car (cdr (cdr x))))))
      ((eq? (car (cdr x)) '*)
       (* (value (car x)) (value (car (cdr (cdr x))))))
      )))

(value '(2 + (3 * 5)))

;对具有相同性质的子部件进行递归调用
; - 列表的子列表
; - 算术表达式的子表达式

(define 1st-sub-exp
  (lambda (aexp)
       (car (cdr aexp))))

(define 2st-sub-exp
  (lambda (aexp)
    (car (cdr (cdr aexp)))))

(define operator
  (lambda (aexp)
    (car aexp)))

(define value2
  (lambda (nexp)
    (cond
      ((atom? nexp) nexp)
      ((eq? (operator nexp) '+)
       (+ (value2 (1st-sub-exp nexp)) (value2 (2st-sub-exp nexp))))
            ((eq? (operator nexp) '*)
       (* (value2 (1st-sub-exp nexp)) (value2  (2st-sub-exp nexp)))))))

(value2 '(* (+ 2 3) 5))

(define sero?
  (lambda x
    (null? x)))

(define edd1
  (lambda x
    (cons '() x)))

(define zub1
  (lambda x
    (cdr x)))

(define addw
  (lambda (n m)
    (cond
      ((sero? m) n)
      (else (edd1 (addw n (sub1 m)))))))
