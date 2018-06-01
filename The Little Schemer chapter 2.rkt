#lang racket
(define atom?
(lambda (x)
  (and (not (pair? x)) (not (null? x)))))

(define lat?
  (lambda (l)
    (cond
      ((null? l) #t)
      ((atom? (car l))(lat? (cdr l)))
      (else #f))))

(lat? '(Jack Sprat could eat no chicken fat))

(lat? '((Jack) Sprat could eat no chicken fat))

(lat? '())

(define member?
  (lambda (x l)
    (cond ((null? l) #f)
          ((eq? x (car l)) #t)
          (else (member? x (cdr l))))))

(member? 'poached '(fried eggs and scrambled eggs))

(member? 'tea '(coffee tea or milk))
