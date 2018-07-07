#lang racket

(define lookup-in-entry
  (lambda (name entry entry-f)
    (lookup-in-entry-help name
                          (first entry)
                          (second entry)
                          entry-f)))

(define lookup-in-entry-help
  (lambda (name names values entry-f)
    (cond
      ((null? names) (entry-f name))
      ((eq? (car names) name) (car values))
      (else (lookup-in-entry-help name (cdr names) (cdr values) entry-f))
      )
    )
  )

(lookup-in-entry 'entree '((appetizer entree beverage) (food tastes good))
                 (lambda (x) (x)))

(define lookup-in-table
  (lambda (name table table-f)
    (cond
      ((null? table) (table-f name))
      ((lookup-in-entry name (car table) (lambda (x) lookup-in-table x (cdr table)
                                            table-f))))))

(lookup-in-table 'entree '(((entree dessert) (spaghetti spumoni)) ((appetizer
                                                                   entree
                                                                   beverage)
                                                                 (food tastes
                                                                       good)))
                 (lambda (x) (x)))

(define expression-to-action
  (lambda (e)
    (cond
      ((atom? e) (atom-to-action e))
      (else (list-to-action e)))))

(define atom-to-action
  (lambda (e)
    (cond
      ((number? e) *const)
      ((eq? e #t) *const)
      ((eq? e (quote cons)) *const)
      ((eq? e (quote car)) *const)
      ((eq? e (quote cdr)) *const)
      ((eq? e (quote null?)) *const)
      ((eq? e (quote eq?)) *const)
      ((eq? e (quote atom?)) *const)
      ((eq? e (quote zero?)) *const)
      ((eq? e (quote add1?)) *const)
      ((eq? e (quote sub1?)) *const)
      ((eq? e (quote number?)) *const)
      (else *identifier))))

(define list-to-action
  (lambda (e)
    (cond
      ((atom? (car e))
       (cond
         ((eq? (car e) (quote quote))
         *quote)
         ((eq? (car e) (quote lambda))
         *lambda)
         ((eq? (car e) (quote lambda))
         *cond)
         (else *application)))
      (else *application))))

(define value
  (lambda (e)
    (meaning e (quote ()))))

(define meaning
  (lambda (e table)
    ((expression-to-action e) e table)))
