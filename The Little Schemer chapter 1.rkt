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
