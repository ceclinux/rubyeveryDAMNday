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

(define eqset?
  (lambda (set1 set2)
(and (subset? set1 set2) (subset? set2 set1))))

(eqset? '(6 large chicken with wings) '(large chicken wings with 6))

(eqset? '(6 large chicken with wings) '(large chicken wings with 7)) 

(define intersect?
  (lambda (set1 set2)
  (cond
    ((null? set1) #f)
    (else (or (member? (car set1) set2) (intersect? (cdr set1) set2))))))

(intersect? '(stewed tomatoes and macaroni) '(marcaroni and cheese))

(intersect? '(stewed tomatoes and macaroni) '(waht cheese))

(define intersect
  (lambda (set1 set2)
    (cond
      ((null? set1) '())
      ((member? (car set1) set2) (cons (car set1) (intersect (cdr set1) set2)))
      (else (intersect (cdr set1) set2)))))

(intersect '(stewed tomatoes and macaroni) '(marcaroni and cheese))

(intersect '(stewed tomatoes and macaroni) '(waht cheese))

(define union
  (lambda (set1 set2)
    (cond
      ((null? set1) set2)
      ((member? (car set1) set2) (union (cdr set1) set2))
      (else (cons (car set1)  (union (cdr set1) set2))))))

(union '(stewed tomatoes casserole macaroni and cheese) '(macaroni and cheese))

(define intersectall
  (lambda (l-set)
    (cond
      ((null? (cdr l-set)) (car l-set))
      (else (intersectall (cons (intersect (car l-set) (car (cdr l-set))) (cdr (cdr l-set))))))))

(intersectall '((6 pears and)
                (3 peaches and 6 peppers)
                (8 pears and 6 plums)
                (and 6 prunes with some apples)))
