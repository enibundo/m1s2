(load "lambda-terms.scm")
(load "mini-langage.scm")

(begin (display "zero : ")  (display (chiffre (make-chiffre 'zero))) (newline))
(begin (display "un : ")    (display (chiffre (make-chiffre 'un))) (newline))
(begin (display "deux : ")  (display (chiffre (make-chiffre 'deux))) (newline))
(begin (display "trois : ") (display (chiffre (make-chiffre 'trois))) (newline))
(begin (display "quatre : ") (display (chiffre (make-chiffre 'quatre))) (newline))
(begin (display "cinq : ")  (display (chiffre (make-chiffre 'cinq))) (newline))
(begin (display "six : ")   (display (chiffre (make-chiffre 'six))) (newline))
(begin (display "sept : ")  (display (chiffre (make-chiffre 'sept))) (newline))
(begin (display "huit : ")  (display (chiffre (make-chiffre 'huit))) (newline))
(begin (display "neuf : ")  (display (chiffre (make-chiffre 'neuf))) (newline))

(define zero-c (make-chiffre 'zero))
(define dix (make-compose (make-simple (make-chiffre 'un)) zero-c))
(define trente-deux
  (make-compose (make-simple (make-chiffre 'trois)) (make-chiffre 'deux)))

(begin (display "0 : ")
       (display (valeur (make-simple (make-chiffre 'zero)))) (newline))
(begin (display "10 : ")
       (display (valeur dix)) (newline))
(begin (display "32 : ")
       (display (valeur trente-deux)) (newline))

(define vrai (inEV #t))
(define faux (inEV #f))

(begin (display vrai) (newline)
       (display faux) (newline))

(define exp-cons0 (make-constante (make-simple zero-c)))
(define exp-cons10 (make-constante dix))
(define exp-cons32 (make-constante trente-deux))

(begin (display "exp-cons32 : ")
       (display (((eval exp-cons32) emptyEnv) emptyStore)) (newline))


(define moins10 (make-moins exp-cons32 exp-cons10))

(begin (display "moins10 : ")
       (display (((eval moins10) emptyEnv) emptyStore)) (newline))

(define res1 (allocate emptyStore))
(define loc1 (cdr res1))
(define sigma1 (((updateStore (car res1)) loc1) (inSV 10)))
(define id-x (make-identificateur 'x))
(define rho1 (((extendEnv emptyEnv) id-x) loc1))

(begin (display "id-x : ")
       (display (((eval id-x) rho1) sigma1)) (newline))


(define tant-que-vrai
  (make-tant-que
    (make-plus-petit exp-cons0 id-x)
    (make-affectation
      id-x
      (make-moins id-x (make-constante (make-simple (make-chiffre 'un)))))))

(begin (display "tant-que-vrai : ")
       (let ((sigma (((execute tant-que-vrai) rho1) sigma1)))
         (display (((eval id-x) rho1) sigma)) (newline)))