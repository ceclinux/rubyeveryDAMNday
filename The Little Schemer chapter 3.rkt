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
      ((eq? old (car lat)) (cons new (cons old (cdr lat))))
      (else (cons car lat) (insertL new old (cdr lat))))))

(insertR 'e 'd '(a b c d f g d h))

(define multiinsertL
  (lambda (new old lat)
    (cond
      ((null? lat) '())
      ((eq? (car lat) old) (cons old (cons new (multiinsertL new old (cdr lat)))))
      (else (cons (car lat) (multiinsertL new old (cdr lat)))))))

(multiinsertL 'topping 'fudge '(ice cream with fudge topping fudge for dessert))               

;在递归时总是改变至少一个参数。该参数必须向着不断接近结束条件而改变。改变的参数必须在结束条件中得以测试：当使用`cdr`时，用`null?`测试是否结束

(define multisubset
  (lambda (new old lat)
    (cond
      ((null? lat) '())
      ((eq? (car lat) old) (cons new (multisubset new old (cdr lat))))
      (else (cons (car lat) (multisubset new old (cdr lat)))))))

(multisubset 'topping 'fudge '(ice cream with fudge topping fudge for dessert)) 

