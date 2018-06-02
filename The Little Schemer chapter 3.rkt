#lang racket

(define member?
  (lambda (a lat)
    (cond
      ((null? lat)#f)
      (else (or (eq? (car lat) a)
                (member? a (cdr lat)))))))

(define remember
  (lambda (a lat)
    (cond
      ((null? lat) '())
      ((eq? a (car lat)) (cdr lat))
      (else (cons (car lat) (remember a (cdr lat)))))))

(remember 'mint '(lamb chops and mint jelly))

(remember 'mint '(lamb chops and flavored mint jelly))

(remember 'cup '(coffee cup tea cup and hick cup))

(define first
  (lambda (x)
    (cond
      ((null? x) '())
      (else (cons (car (car x)) (first (cdr x)))))))

(first '((apple peach pumpkin) (plum pear cherry) (grape raisin pea) (bean carrot eggplant)))

;scheme十诫第二诫：使用cons来构建列表

;构建一个列表的时候，描述第一个典型元素，之后cons到元素的一般性递归上
                 
