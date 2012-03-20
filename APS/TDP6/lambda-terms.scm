;;; Université Pierre et Marie Curie, Master informatique, Spécialité STL
;;; Unité d'enseignement Analyse des programmes et sémantique (APS)
;;; (c) - Jacques Malenfant, 2012

;*******************************************************************************
; Abstract syntax
;
; term ::= v | (term term) | (lambda v term)
;
;*******************************************************************************

; variables
(define (make-var symb) symb)

(define (var? term)     (symbol? term))

; abstractions
(define (make-abstraction var body)
  (list 'lambda var body))

(define (get-formal abstraction)
  (cadr abstraction))

(define (get-body abstraction)
  (caddr abstraction))

(define (abstraction? term)
  (and (list? term) (equal? (car term) 'lambda)))

; applications
(define (make-application operator operand)
  (list operator operand))

(define (get-operator application)
  (car application))

(define (get-operand application)
  (cadr application))

(define (application? term)
  (and (list? term) (not (abstraction? term))))
