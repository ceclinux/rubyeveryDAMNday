#lang racket

(define atom?
(lambda (x)
  (and (not (pair? x)) (not (null? x)))))


(define remember*
  (lambda (a lat)
    (cond
    ((null? lat) '())
    ((not (atom? (car lat))) (cons (remember* a (car lat)) (remember* a (cdr lat)))) 
    ((eq? a (car lat)) (remember* a (cdr lat)))
    (else (cons (car lat) (remember* a (cdr lat)))))))

(remember* 'cup '((coffee) cup ((tea) cup) (and (hick)) cup))

(define insertR*
  (lambda (new old lat)
    (cond
      ((null? lat) '())
      ((atom? (car lat))
       (cond
         ((eq? (car lat) old) (cons old (cons new (insertR* new old (cdr lat)))))
         (else (cons (car lat) (insertR* new old (cdr lat))))))
       (else (cons (insertR* new old (car lat)) (insertR* new old (cdr lat)))))))


(insertR* 'roast 'chuck '((how much (wood))
                          could
                          ((a (wood) chuck))
                          (((chuck)))
                          (if (a) ((wood chuck)))
                          could chuck wood))

;当对一个院子列表lat进行递归调用时，询问两个有关lat的问题：(null? lat) 和 else
;当对一个数字n进行递归调用时，询问两个有关n的问题：(zero? n)和else
;当对一个S-表达式尽心递归调用时，询问三个有关l的问题：(null? lat)、(atom? (car l))和else

;点解？

;因为所有的*函数所处理的列表，都满足以下情况的一种：
; 空列表
; 一个原子cons在一个列表上
; 一个列表cons在另一个列表上

;在递归时总是改变至少一个参数。当对一个院子列表lat进行递归调用时候，使用(cdr lat)。
;当对数字n进行递归调用时，使用(sub1 n)
;当对一个S-表达式进行递归调用时，只要是(null? l)和(atom? (car ll))都不为true，那么就同时使用(car l)和(cdr l)

;在递归时改变的参数，必须向着不断接近结束条件而改变。改变的参数必须在结束条件中得以测试
;当使用cdr时，用nill?测试是否结束；
;当使用sub1时，用zero?测试是否结束

(define occur*
  (lambda (a l)
    (cond
      ((null? l) 0)
      ((atom? (car l))
        (cond
          ((eq? a (car l)) (add1 (occur* a (cdr l))))
          (else (occur* a (cdr l)))
          ))
      (else (+ (occur* a (car l)) (occur* a (cdr l)))))))

(occur* 'banana '((banana)
                  (split ((((banana ice)))
                          (cream (banana))
                          sherbet))
                  (banana)
                  (bread)
                  (banana brandy)))

(define subst*
  (lambda (new old l)
    (cond
      ((null? l) '())
      ((atom? (car l))
       (cond
         ((eq? old (car l)) (cons new (subst* new old (cdr l))))
         (else  (cons (car l) (subst* new old (cdr l))))))
      (else (cons (subst* new old (car l)) (subst* new old (cdr l)))))))

(subst* 'orange 'banana 
          '((banana)
            (split ((((banana ice)))
                    (cream (banana))
                    sherbet))
            (banana)
            (bread)
            (banana brandy)))

(define insertL*
  (lambda (new old l)
    (cond
      ((null? l) '())
      ((atom? (car l))
       (cond
         ((eq? (car l) old) (cons new (cons old (insertL* new old (cdr l)))))
         (else (cons (car l) (insertL* new old (cdr l))))))
      (else (cons (insertL* new old (car l)) (insertL* new old (cdr l)))))))

(insertL* 'pecker 'chuck '((how much (wood))
                          could
                          ((a (wood) chuck))
                          (((chuck)))
                          (if (a) ((wood chuck)))
                          could chuck wood))

(define member*
  (lambda (a l)
    (cond
      ((null? l) #f)
      ((atom? (car l))
       (cond
         ((eq? (car l) a) #t)
         (else (member* a (cdr l)))))
      (else (or (member* a (car l)) (member* a (cdr l)))))))

(member* 'chips '((potato) (chips ((with) fish) (chips))))
       
