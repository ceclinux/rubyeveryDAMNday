#lang racket

(define pick
  (lambda (num lat)
    (cond
      ((eq? num 0) (car lat))
      (else (pick (- num 1) (cdr lat)))
      )
    )
  )

(define looking
  (lambda (a lat)
    (keep-looking a (pick 1 lat) lat)))

(define keep-looking
  (lambda (a sorn lat)
    (cond
      ((number? sorn) (keep-looking a (pick sorn lat) lat))
      (else (eq? sorn a))
      )
    )
  )

(keep-looking 'caviar 3 '(6 2 4 caviar 5 7 3))

; 我们把looking这样的函数称之为部分函数，怎么称呼我们之前我们接触的函数

; 全函数(total function)


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

(define shift
  (lambda (pair)
    (build
      (first (first pair))
      (cons
        (second (first pair))
        (cdr pair)
        )
      )
    )
  )

(shift '((a b) c))
(shift '((a b)(c d)))
