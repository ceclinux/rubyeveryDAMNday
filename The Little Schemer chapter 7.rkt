#lang racket
(define member?
  (lambda (a lat)
    (cond
      ((null? lat)#f)
      (else (or (eq? (car lat) a)
                (member? a (cdr lat)))))))

(member? 'a '(a b))

(define set?
  (lambda (x)
    (cond
      ((null? x) #t)
      (else
       (cond
              ((member? (car x) (cdr x)) #f)
              (else (set? (cdr x))))))))

(set? '(apples pin))

(define makeset
  (lambda (lat)
    (cond
      ((null? lat) '())
      ((member? (car lat) (cdr lat)) (makeset (cdr lat)))
      (else (cons (car lat) (makeset (cdr lat)))))))

(makeset '(apple peach pear peach plum apple lemon peach))

(define multiremember
  (lambda (x lat)
    (cond
      ((null? lat) lat)
      ((eq? (car lat) x) (multiremember x (cdr lat)))
      (else (cons (car lat) (multiremember x (cdr lat)))))))

(multiremember 'cup '(coffee cup tea cup and hick cup))

(define makeset2
  (lambda (lat)
    (cond
      ((null? lat) '())
      ((cons (car lat) (makeset2 (multiremember (car lat) (cdr lat))))))))

(makeset2 '(apple peach pear peach plum apple lemon peach))

(define subset?
  (lambda (set1 set2)
    (cond
      ((null? set1) #t)
      (else (and (member? (car set1) set2) (subset? (cdr set1) set2))))))

(subset? '(5 chicken wings)
         '(5 hamburgers 2 pices fired chicken and light duckiling wings))
