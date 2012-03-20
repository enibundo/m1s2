(define (newline)
  (display "\n"))

(define (mydisplay f)
  (display f)
  (newline))

(define (make-set l)
  (list 'set l))

(define (empty-set)
  (make-set (list)))

(define (is-set? s)
  (and
   (list? (cadr s))
   (equal? (car s) 'set)))

(define (get-list-of-set s)
  (cadr s))

(define (in? set el)
  (not (null? (member  el (get-list-of-set set)))))

(define (union set1 set2)
  (make-set (append (get-list-of-set set1)
		    (get-list-of-set set2))))

(define (listintersection l1 l2)
  (if (null? l1)
      (list)
      (if (not (member (car l1) l2))
	  (listintersection (cdr l1) l2)
	  (cons (car l1) (listintersection (cdr l1) l2)))))
(define (intersection set1 set2)
  (let* ((list1 (get-list-of-set set1))
	 (list2 (get-list-of-set set2)))
    (make-set (listintersection list1 list2))))

(define (removeelementfromlist e l)
  (if (null? l)
      (list)
      (if (equal? e (car l))
	  (removeelementfromlist e (cdr l))
	  (cons (car l) (removeelementfromlist e (cdr l))))))

(define (listdifference l1 l2)
  (if (null? l2)
      l1
      (if (member (car l2) l1)
	  (listdifference (removeelementfromlist (car l2) l1) (cdr l2))
	  (listdifference l1 (cdr l2)))))

(define (difference set1 set2)
  (let* ((list1 (get-list-of-set set1))
	 (list2 (get-list-of-set set2)))
    (make-set (listdifference list1 list2)))) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (free-variables terme)
  (if (abstraction? terme)
      (difference (make-set (free-variables (get-body terme))) (get-formal terme))
      



(mydisplay (make-set (list 1 2 3)))
(mydisplay (is-set? (make-set (list 1 2 3))))
(mydisplay (get-list-of-set (make-set (list 1 2 3))))
(mydisplay (in? (make-set (list 1 2 3)) 3))
(mydisplay (in? (make-set (list 1 2 3)) 123))


(mydisplay (union (make-set '(1 2 3))
		  (make-set '(4 5 6))))

(mydisplay (intersection (make-set '(1 2 3))
			 (make-set '(1 5 6 3))))

