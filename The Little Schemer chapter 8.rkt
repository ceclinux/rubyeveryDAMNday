#lang racket

(define remember-f
  (lambda (test? a l)
    (cond
      ((null? l) '())
      ((test? a (car l)) (cdr l))
      (else (cons (car l) (remember-f test? a (cdr l)))))))

(remember-f equal? '(pop corn) '(lemonade (pop corn) and (cake)))

(define eq?-c
(lambda (a)
  (lambda (x)
    (eq? x a))))

(define eq?-salad (eq?-c 'salad))

(eq?-salad 'salad)

((eq?-c 'salad) 'tuna)

(define rember-f
  (lambda (test?)
    (lambda (a l)
      (cond
        ((null? l) (quote ()))
        ((test? (car l) a) (cdr l))
        (else (cons (car l)
                    ((rember-f test?) a
                       (cdr l))))))))

((rember-f eq?) 'tuna '(shrimp salad and tuna salad))

(define insertL
  (lambda (test?)
    (lambda (new old lat)
      (cond
        ((null? lat) '())
        ((test? old (car lat)) (cons new (cons old (cdr lat))))
        (else (cons (car lat) ((insertL test?) new old (cdr lat))))))))

((insertL eq?) 'wa 'ta '(cc ta jj))

(define insert-g
  (lambda (seq)
    (lambda (new old l)
      (cond
        ((null? l) '())
        ((eq? (car l) old)
         (seq new old (cdr l))) 
        (else (cons (car l) ((insert-g seq) new old (cdr l))))))))

(define seqL
  (lambda (new old l)
    (cons new (cons old l))))

(define insertL2 (insert-g seqL))

(insertL2  'wa 'ta '(cc ta jj))

(define insertL3
  (insert-g
   (lambda (new old l)
     (cons new (cons old l)))))

(define seqS
  (lambda (new old l)
    (cons (new l))))

(define subst (insert-g seqS))

;用函数来抽象通用形式

(define atom-to-function
  (lambda (x)
    (cond
      ((eq? x '+) +)
      ((eq? x '*) *)
      (else exp))))

(define atom? 
  (lambda (x)
    (and (not (pair? x)) (not (null? x)))))

(define 1st-sub-exp
  (lambda (aexp)
       (car (cdr aexp))))

(define 2st-sub-exp
  (lambda (aexp)
    (car (cdr (cdr aexp)))))

(define operator
  (lambda (aexp)
(car aexp)))

 (define value
   (lambda (nexp)
     (cond
       ((atom? nexp) nexp)
     (else ((atom-to-function (operator nexp)) (value (1st-sub-exp nexp)) (value (2st-sub-exp nexp)))))))

(value '(* (+ 2 3) 5))

(define eq?-tuna
  (eq?-c (quote tuna)))

(eq?-tuna 'tuna)

(define multiremberT
  (lambda (test?)
    (lambda (lat)
    (cond
      ((null? lat) '())
      ((test? (car lat))
             ((multiremberT test?) (cdr lat)))
      (else (cons (car lat) ((multiremberT test?) (cdr lat))))))))

((multiremberT eq?-tuna) '(shrimp salad tuna salad and tuna))

(define multiremember&co
  (lambda (a lat col)
    (cond
      ((null? lat)
       (col (quote()) (quote())))
      ((eq? (car lat) a)
       (multiremember&co a
          (cdr lat)
           (lambda (newlat seen)
             (col newlat
                  (cons (car lat) seen)))))
    (else
     (multiremember&co a
                       (cdr lat)
                       (lambda (newlat seen)
                         (col (cons (car lat) newlat)
                              seen)))))))

;col是"collector"的缩写。collector有时又被称作"continuation"

;scheme十戒之第十戒
;构建函数，一次收集多个值

;(multirember&co a lat f)是做什么的
;其查找lat的每个原子，判断该原子是否等于`(eq?) a`。那些条件判断为假的原子被收集在ls1列表中；条件判断为真的额其他原子则被收集到了
;第二个列表ls2中。最后，该函数判断(f ls1 ls2)的值

(define multiinsertLR
  (lambda (new oldL oldR lat)
    (cond
      ((null? lat) '())
      ((eq? oldL (car lat))
       (cons (cons new oldL) (multiinsertLR new oldL oldR (cdr lat))))
       ((eq? oldR (car lat))
       (cons (cons  oldR new) (multiinsertLR new oldL oldR (cdr lat))))
       (else (cons (car lat) (multiinsertLR new oldL oldR (cdr lat)))))))

(define evens-only*
  (lambda (l)
    (cond
      ((null? l) '())
      ((atom? (car l))
        (cond
          ((even? (car l))
           (cons (car l)
                 (evens-only* (cdr l))))
          (else (evens-only* (cdr l)))))
      (else (cons (evens-only* (car l))
                  (evens-only* (cdr l)))))))

(evens-only* '((9 1 2 8) 3 10 ((9 9) 7 6) 2))

(define evens-only*&co
  (lambda (l col)
    (cond
      ((null? l)
       (col '() 1 0))
      ((atom? (car l))
              (cond
                ((even? (car l))
                       (evens-only*&co (cdr l)
                                       (lambda (newl p s)
                                         (col (cons (car l) newl)
                                          (* (car l) p) s))))
                (else (evens-only*&co (cdr l)
                                      (lambda (newl p s)
                                        (col newl
                                             p (+ (car l) s)))))
                ))
      (else (evens-only*&co (car l)
                                      (lambda (newl p s)
                                        (evens-only*&co (cdr l)
                                    (lambda (newl2 p2 s2)
                                        (col (cons newl newl2)
                                             (* p p2) (+ s s2))))))))))

(define the-last-friend
  (lambda (newl product sum)
    (cons sum
          (cons product
                newl))))

(evens-only*&co '((9 1 2 8) 3 10 ((9 9) 7 6) 2) the-last-friend)
