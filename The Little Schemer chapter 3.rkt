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

(define insertR
  (lambda (new old lat)
    (cond
      ((null? lat) '())
      ((eq? old (car lat)) (cons old (cons new (cdr lat))))
      (else (cons (car lat) (insertR new old (cdr lat)))))))

(insertR 'e 'd '(a b c d f g d h))

(define insertL
  (lambda (new old lat)
    (cond
      ((null? lat) '())
      ((eq? old (car lat)) (cons new lat))
      (else (cons (car lat) (insertL new old (cdr lat)))))))

(insertL 'e 'd '(a b c d f g d h))

(define subst
  (lambda (new old lat)
    (cond
      ((null? lat) '())
      ((eq? old (car lat)) (cons new (cdr lat)))
      (else (cons (car lat) (subst new old (cdr lat)))))))

(subst 'topping 'fudge   '(ice cream with fudge for dessert))

(define subst2
  (lambda (new o1 o2 lat)
    (cond
      ((null? lat) '())
      ((or (eq? o1 (car lat)) (eq? o2 (car lat))) (cons new (cdr lat)))
      (else (cons (car lat) (subst2 new o1 o2 (cdr lat)))))))

(subst2 'vanilla 'chocolate 'banana '(banana ice cream with chocolate topping))

(define multirember
  (lambda (a lat)
    (cond
      ((null? lat) '())
      ((eq? a (car lat)) (multirember a (cdr lat)))
      (else (cons (car lat) (multirember a (cdr lat)))))))

(multirember 'cup '(coffee cup tea cup and hick cup))
