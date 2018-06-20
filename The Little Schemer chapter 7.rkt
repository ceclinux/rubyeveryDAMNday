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

(define atom?
(lambda (x)
  (and (not (pair? x)) (not (null? x)))))

(define a-pair?
  (lambda (x)
    (cond
      ((atom? x) #f)
      ((null? x) #f)
      ((null? (cdr x)) #f)
      ((null? (cdr (cdr x))) #t)
      (else #f))))
       
(a-pair? '(3 9))

(define first
  (lambda (p)
    (cond
      (else (car p)))))

(define second
  (lambda (p)
    (cond
      (else (car (cdr p))))))

(define build
  (lambda (s1 s2)
    (cond
      (else (cons s1
                  (cons s2 '()))))))

(define firsts
  (lambda (x)
    (cond
      ((null? x) '())
      (else (cons (first (car x)) (firsts (cdr x)))))))

(define fun?
  (lambda (rel)
    (set? (firsts rel))))

(fun? '((8 3) (4 2) (7 6) (6 2) (3 4)))

(fun? '((d 4) (b 0) (b 9) (6 2) (3 4)))

(define revrel
  (lambda (rel)
    (cond
      ((null? rel) '())
      (else (cons (build (second (car rel)) (first (car rel))) (revrel (cdr rel)))))))

(revrel '((8 a) (pumpkin pie) (got sick)))

(define revpair
  (lambda (pair)
    (build (second pair) (first pair))))

(define revrel2
  (lambda (rel)
    (cond
      ((null? rel) '())
      (else (cons (revpair (first rel)) (revrel2 (cdr rel)))))))

(revrel2 '((8 a) (pumpkin pie) (got sick)))

(define one-to-one?
  (lambda (fun)
    (fun? (revrel fun))))

(one-to-one? '((grape raisin)
              (plum prune)
              (stewed prune)))

(one-to-one? '((grape raisin)
              (plum prune)
              (stewed t)))
