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
