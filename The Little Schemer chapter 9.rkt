#lang racket


(define atom?
  (lambda (x)
    (and (not (pair? x)) (not (null? x)))))

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

(define length*
  (lambda (pora)
    (cond
      ((atom? pora) 1)
      (else (+ (length* (first pora)) (length* (second pora)))
      )
    )
  )
  )

(length* '((a b) c))
(length* '((a b)(c d)))

; (define shuffle
  ; (lambda (pora)
    ; (cond
      ; ((atom? pora) pora)
      ; ((a-pair? (ifrst pora))
       ; (shuffle (revpair pora)))
      ; (else (build (first pora) (shuffle (second pora)))))))

; shuffle并不是全函数，因为它交换了pair的两个组成，这意味着我们又得重来
