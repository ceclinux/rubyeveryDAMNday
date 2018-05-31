#lang racket

(define atom?
(lambda (x)
  (and (not (pair? x)) (not (null? x)))))

(atom? (quote ()))

(atom? (quote atom))

(atom? 'turkey)

(atom? 1492)

(atom? 'u)

(atom? '*abc$)

(list? '(atom))

(list? '(atom turkey or))

;(list? '(atom turkey) 'or) 不是，因为实际上这是未用括号括起来的两个表达式。第一个S-表达式是一个列表，包含两个原子，第二个S-表达式是一个原子



;(list? ('(atom turkey) 'or)) 是的，印着这时候两个`S-`表达式用括号括起来了

; In computing, s-expressions, sexprs or sexps (for "symbolic expression") are a notation for nested list (tree-structured) data, invented for and popularized by the programming language Lisp, which uses them for source code as well as data. In the usual parenthesized syntax of Lisp, an s-expression is classically defined[1] as
; 
;     an atom, or
;     an expression of the form (x . y) where x and y are s-expressions.


; 是的，所有原子都是S-表达式
'xyz
; 是的，因为他是一个列表
'(x y z)
; 是的，因为所有列表都是S-表达式
'('(x y))
; 是的，因为他用括号把一个S-表达式集合起来了, 该列表里面一共有6个S-表达式
'(how are you doing so far)
; 是的，，因为他用括号把一个S-表达式集合起来了，该列表一共有三个S-表达式，'('(how) are)，'('(you) '(doing so))，far
'('('(how) are) '('(you) '(doing so)) far)

(list? '())

(atom? '())

(list? '('() '() '() '()))

(car '(a b c))

(car '('(a b c) x y z))

;不能请求一个原子的car
;(car 'hotdog)

;不能求空列表的car
;(car '())

; Scheme五法之一，car之法则
;基本yuanjaincar仅定义为针对非空列表

(car '('( '(hotdogs)) '(and) '(pickle) 'relish))

(car (car '(((hotdogs)) '(and))))

;因为(b c)是列表l扣除(car l)的部分
(cdr '(a b c))

(cdr '('(x) 't 'r))

;不能请求一个原子的cdr
;(cdr 'hotdogs)

;不能请求空列表的cdr
;(cdr '())

;基本cdr仅定义为针对非空列表。任意非空列表的cdr总是另一个列表

(car (cdr '('(b) '(x y) '((c)))))

(cdr (cdr '('(b)'(x y)'((c)))))

;没有答案，因为(car l)是个原子，cdr不能以原子为参数
;(cdr (car '(a '(b '(c))d )))

;car与cdr都已非空列表作为参数

(cons 'peanut '(butter and jelly))

;因为cons添加任意的S-表达式到列表开头chu
(cons '(banana and) '(peanut butter and jelly))

(cons '((help) this) '(is very ((hard) to learn)))

;cons 有两个参数：第一个参数是任意S-表达式，第二个参数是任意列表

(cons '(a b (c)) '())

(cons 'a '())

;第二个参数l必须是列表
;(cons '((a b c)) 'b)

;(cons 'a 'b)

;Scheme五法之第三法：cons法则 基本元件cons需要两个参数。第二个参数必须是一个列表。结果是一个列表

(cons 'a (cdr '((b) c d)))

;Returns #t if v is the empty list, #f otherwise.
(null? '())

(null? '(a b c))

(null? 'spaghetti)

;基本元件null?仅定义为针对列表

;atom 有一个参数 该参数是任意的S-表达式

(atom? (car '(harry had a heap of apples)))

(atom? (cdr '(Harry had a heap of apples)))

(atom? (cdr '(harry)))

(atom? (car (cdr '(swing low sweet cherry oat))))

(eq? 'Harry 'Harry)

(eq? 'margarin 'butter)

;eq?有两个参数，都必须是非数字原子

(eq? '() '(strawberry))

(eq? 6 7)

;eq之法则：基本元件eq?需要两个参数。每个参数必须是一个非数字的原子

(eq? (car '(Mary had a little lamb chop)) 'Mary)

;不能比较
;(eq? (cdr '(soured milk) 'milk))

(eq? (car '(beans beans we need jelly beans))(car (cdr '(beans beans we need jelly beans))))
