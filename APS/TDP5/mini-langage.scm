;
; Semantique denotationnelle d'un mini-lagage imperatif
;
; Cours MI030 - Ananlyse des programmes et sémantiques
;
; Auteur : Jacques.Malenfant@lip6.fr
;

;****************************************************************************
;
; Catégories syntaxiques et syntaxe abstraite
;
; ins in Instructions
; e in Expressions
; i in Identificateurs
; n in Numeraux
; c in Chiffre
;
; ins ::= seq ins1 ins2 | if e ins1 ins2 | while e ins | i := e
; e   ::= e1 + e2 | e1 - e2 | e1 * e2 | e1 / e2 | e1 & e2 | e1 | e2 |
;         e1 < e2 | e1 = e2 | not e2 | n
; n   ::= c | n c
; c   ::= zero | un | deux | trois | quatre | cinq | six | sept | huit | neuf
;
;****************************************************************************

(define (inst? ins)
  (or (seq? ins) (si? ins) (tant-que? ins) (affectation? ins)))

(define (e? e)
  (or (plus? e) (moins? e) (muliplie-par? e) (divise-par? e)
      (et? e) (ou? e) (plus-petit? e) (egal? e) (non? e)))

(define (n? n)
  (or (compose? n) (simple? n)))

(define (seq? ins)          (equal? (vector-ref ins 0) 'seq))
(define (si? ins)           (equal? (vector-ref ins 0) 'si))
(define (tant-que? ins)     (equal? (vector-ref ins 0) 'tant-que))
(define (affectation? ins)  (equal? (vector-ref ins 0) 'affectation))
(define (plus? e)           (equal? (vector-ref e 0) 'plus))
(define (moins? e)          (equal? (vector-ref e 0) 'moins))
(define (multiplie-par? e)  (equal? (vector-ref e 0) 'multiplie-par))
(define (divise-par? e)     (equal? (vector-ref e 0) 'divise-par))
(define (et? e)             (equal? (vector-ref e 0) 'et))
(define (ou? e)             (equal? (vector-ref e 0) 'ou))
(define (plus-petit? e)     (equal? (vector-ref e 0) 'plus-petit))
(define (egal? e)           (equal? (vector-ref e 0) 'egal))
(define (non? e)            (equal? (vector-ref e 0) 'non))
(define (constante? e)      (equal? (vector-ref e 0) 'constante))
(define (identificateur? i) (equal? (vector-ref i 0) 'identificateur))
(define (compose? n)        (equal? (vector-ref n 0) 'compose))
(define (simple? n)         (equal? (vector-ref n 0) 'simple))
(define (chiffre? c)        (equal? (vector-ref c 0) 'chiffre))

(define (make-seq ins1 ins2)       (vector 'seq ins1 ins2))
(define (make-si e ins1 ins2)      (vector 'si e ins1 ins2))
(define (make-tant-que e ins)      (vector 'tant-que e ins))
(define (make-affectation i e)     (vector 'affectation i e))
(define (make-plus e1 e2)          (vector 'plus  e1 e2))
(define (make-moins e1 e2)         (vector 'moins  e1 e2))
(define (make-multiplie-par e1 e2) (vector 'multiplie-par  e1 e2))
(define (make-divise-par e1 e2)    (vector 'divise-par  e1 e2))
(define (make-et e1 e2)            (vector 'et  e1 e2))
(define (make-ou e1 e2)            (vector 'ou  e1 e2))
(define (make-plus-petit e1 e2)    (vector 'plus-petit  e1 e2))
(define (make-egal e1 e2)          (vector 'egal e1 e2))
(define (make-non e)               (vector 'non e))
(define (make-constante n)         (vector 'constante n))
(define (make-identificateur s)    (vector 'identificateur s))
(define (make-compose n c)         (vector 'compose n c))
(define (make-simple c)            (vector 'simple c))
(define (make-chiffre c)           (vector 'chiffre c))

(define (seq->ins1 ins)       (vector-ref ins 1))
(define (seq->ins2 ins)       (vector-ref ins 2))
(define (si->e ins)           (vector-ref ins 1))
(define (si->ins1 ins)        (vector-ref ins 2))
(define (si->ins2 ins)        (vector-ref ins 3))
(define (tant-que->e ins)     (vector-ref ins 1))
(define (tant-que->ins ins)   (vector-ref ins 2))
(define (affectation->i ins)  (vector-ref ins 1))
(define (affectation->e ins)  (vector-ref ins 2))
(define (plus->e1 e)          (vector-ref e 1))
(define (plus->e2 e)          (vector-ref e 2))
(define (moins->e1 e)         (vector-ref e 1))
(define (moins->e2 e)         (vector-ref e 2))
(define (multiplie-par->e1 e) (vector-ref e 1))
(define (multiplie-par->e2 e) (vector-ref e 2))
(define (divise-par->e1 e)    (vector-ref e 1))
(define (divise-par->e2 e)    (vector-ref e 2))
(define (et->e1 e)            (vector-ref e 1))
(define (et->e2 e)            (vector-ref e 2))
(define (ou->e1 e)            (vector-ref e 1))
(define (ou->e2 e)            (vector-ref e 2))
(define (plus-petit->e1 e)    (vector-ref e 1))
(define (plus-petit->e2 e)    (vector-ref e 2))
(define (egal->e1 e)          (vector-ref e 1))
(define (egal->e2 e)          (vector-ref e 2))
(define (non->e e)            (vector-ref e 1))
(define (constante->n e)      (vector-ref e 1))
(define (compose->n n)        (vector-ref n 1))
(define (compose->c n)        (vector-ref n 2))
(define (simple->c n)         (vector-ref n 1))
(define (chiffre->c c)        (vector-ref c 1))
(define (identificateur->s i) (vector-ref i 1))



;****************************************************************************
;
; Domaines et fonctions semantiques
;
; Integer = les entiers de Scheme
; Boolean = les booleens de Scheme
; EV = int(Integer) + bool(Boolean)
; SV = int(Integer) + bool(Boolean)
; DV = EV + var(Location)
; Location = les entiers positifs de Scheme
; Env : Identificateur -> DV + unbound
; Store : Location -> SV + unused + undefined
; 
;****************************************************************************

(define (inLoc n)      (vector 'var n))
(define (Loc? loc)     (equal? (vector-ref loc 0) 'var))
(define (Loc->int loc) (vector-ref loc 1))

(define (inEV v) (if (integer? v) (vector 'int v) (vector 'bool v)))
(define (EVint? ev) (equal? (vector-ref ev 0) 'int))
(define (EVbool? ev) (equal? (vector-ref ev 0) 'bool))
(define (EV->int ev)
  (if (equal? (vector-ref ev 0) 'int)
    (vector-ref ev 1)
    (begin (display "erreur de type dans EV : ")
           (display ev) (newline))))
(define (EV->bool ev)
  (if (equal? (vector-ref ev 0) 'bool)
    (vector-ref ev 1)
    (begin (display "erreur de type dans EV : ")
           (display ev) (newline))))

(define (inSV v) (if (integer? v) (vector 'int v) (vector 'bool v)))
(define (SVint? ev) (equal? (vector-ref ev 0) 'int))
(define (SVbool? ev) (equal? (vector-ref ev 0) 'bool))
(define (SV->int sv)
  (if (equal? (vector-ref sv 0) 'int)
    (vector-ref sv 1)
    (begin (display "erreur de type dans SV : ")
           (display sv) (newline))))
(define (SV->bool sv)
  (if (equal? (vector-ref sv 0) 'bool)
    (vector-ref sv 1)
    (begin (display "erreur de type dans SV : ")
           (display sv) (newline))))

(define (inDV v)
  (if (Loc? v)
    v
    (if (integer? v)
      (vector 'int v)
      (vector 'bool v))))
(define (DVint? ev) (equal? (vector-ref ev 0) 'int))
(define (DVbool? ev) (equal? (vector-ref ev 0) 'bool))
(define (DVLoc? ev) (equal? (vector-ref ev 0) 'var))
(define (DV->int dv)
  (if (equal? (vector-ref dv 0) 'int)
    (vector-ref dv 1)
    (begin (display "erreur de type dans DV : ")
           (display dv) (newline))))
(define (DV->bool dv)
  (if (equal? (vector-ref dv 0) 'bool)
    (vector-ref dv 1)
    (begin (display "erreur de type dans DV : ")
           (display dv) (newline))))
(define (DV->var dv)
  (if (equal? (vector-ref dv 0) 'var)
    (vector-ref dv 1)
    (begin (display "erreur de type dans DV : ")
           (display dv) (newline))))


(define emptyEnv (lambda (i) 'unbound))

(define extendEnv
  (lambda (rho)
    (lambda (i)
      (lambda (dv)
        (lambda (i1)
          (if (and (identificateur? i1)
                   (equal? (identificateur->s i) (identificateur->s i1)))
            dv
            (rho i1)))))))

(define applyEnv
  (lambda (rho)
    (lambda (i)
      (rho i))))


(define emptyStore (lambda (loc) 'unused))
(define updateStore
  (lambda (sigma)
    (lambda (loc)
      (lambda (sv)
        (lambda (loc1)
          (if (= (Loc->int loc) (Loc->int loc1))
            sv
            (sigma loc1)))))))

(define allocate
  (lambda (sigma)
    (letrec ((recherche (lambda (n)
                          (if (equal? (sigma n) 'unused)
                            n
                            (recherche (+ n 1))))))
      (let ((loc (inLoc (recherche 0))))
        (cons (((updateStore sigma) loc) 'undefined) loc)))))

(define deallocate
  (lambda (sigma)
    (lambda (loc)
      (((updateStore sigma) loc) 'unused))))



;****************************************************************************
;
; Equations semantiques
;
; execute : Instructions -> Env -> Store -> Store
; eval : Expressions -> Env -> Store -> EV
; valeur : Numeraux -> EV
; chiffre : Chiffres -> EV
;
;****************************************************************************

(define (execute ins)
  (cond ((seq? ins)      (execute-seq ins))
        ((si? ins)       (execute-si  ins))
        ((tant-que? ins) (execute-tant-que ins))
        ((affectation? ins) (execute-affectation ins))
        (else            (begin
                           (display "erreur : instruction inconnue : ")
                           (display ins) (newline)))))

(define (execute-seq ins)
  (lambda (rho)
    (lambda (sigma)
      (((execute (seq->ins2 ins)) rho)
                                  (((execute (seq->ins1 ins)) rho) sigma)))))

(define (execute-si ins)
  (lambda (rho)
    (lambda (sigma)
      (let ((ev (((eval (si->e ins)) rho) sigma)))
        (if (EV->bool ev)
          (((execute (si->ins1 ins)) rho) sigma)
          (((execute (si->ins2 ins)) rho) sigma))))))

(define (execute-tant-que ins)
  (lambda (rho)
    (lambda (sigma)
      (letrec ((loop (lambda (sigma)
                       (let ((ev (((eval (tant-que->e ins)) rho) sigma)))
                         (if (EV->bool ev)
                           (loop (((execute (tant-que->ins ins)) rho) sigma))
                           sigma)))))
        (loop sigma)))))

(define (execute-affectation ins)
  (lambda (rho)
    (lambda (sigma)
      (((updateStore sigma) ((applyEnv rho) (affectation->i ins)))
                               (((eval (affectation->e ins)) rho) sigma)))))

(define (eval e)
  (cond ((plus? e)           (eval-plus e))
        ((moins? e)          (eval-moins e))
        ((multiplie-par? e)  (eval-multiplie-par e))
        ((divise-par? e)     (eval-divise-par e))
        ((et? e)             (eval-et e))
        ((ou? e)             (eval-ou e))
        ((plus-petit? e)     (eval-plus-petit e))
        ((egal? e)           (eval-egal e))
        ((non? e)            (eval-non e))
        ((constante? e)      (eval-constante e))
        ((identificateur? e) (eval-identificateur e))
        (else                (begin
                               (display "erreur : expression inconnue : ")
                               (display e) (newline)))))

(define (eval-plus e)
  (lambda (rho)
    (lambda (sigma)
      (inEV (+ (EV->int (((eval (plus->e1 e)) rho) sigma))
               (EV->int (((eval (plus->e2 e)) rho) sigma)))))))

(define (eval-moins e)
  (lambda (rho)
    (lambda (sigma)
      (inEV (- (EV->int (((eval (moins->e1 e)) rho) sigma))
               (EV->int (((eval (moins->e2 e)) rho) sigma)))))))

(define (eval-multiplie-par e)
  (lambda (rho)
    (lambda (sigma)
      (inEV (* (EV->int (((eval (multiplie-par->e1 e)) rho) sigma))
               (EV->int (((eval (multiplie-par->e2 e)) rho) sigma)))))))

(define (eval-divise-par e)
  (lambda (rho)
    (lambda (sigma)
      (inEV (quotient (EV->int (((eval (divise-par->e1 e)) rho) sigma))
                      (EV->int (((eval (divise-par->e2 e)) rho) sigma)))))))

(define (eval-et e)
  (lambda (rho)
    (lambda (sigma)
      (inEV (and (EV->bool (((eval (et->e1 e)) rho) sigma))
                 (EV->bool (((eval (et->e2 e)) rho) sigma)))))))

(define (eval-ou e)
  (lambda (rho)
    (lambda (sigma)
      (inEV (or (EV->bool (((eval (ou->e1 e)) rho) sigma))
                (EV->bool (((eval (ou->e2 e)) rho) sigma)))))))

(define (eval-plus-petit e)
  (lambda (rho)
    (lambda (sigma)
      (inEV (< (EV->int (((eval (plus-petit->e1 e)) rho) sigma))
               (EV->int (((eval (plus-petit->e2 e)) rho) sigma)))))))

(define (eval-egal e)
  (lambda (rho)
    (lambda (sigma)
      (let ((ev1 (((eval (egal->e1 e)) rho) sigma))
            (ev2 (((eval (egal->e2 e)) rho) sigma)))
        (if (EVbool? ev1)
          (inEV (equal? (EV->bool ev1) (EV->bool ev2)))
          (inEV (equal? (EV->int ev1) (EV->int ev2))))))))

(define (eval-non e)
  (lambda (rho)
    (lambda (sigma)
      (inEV (not (EV->bool (((eval (non->e e)) rho) sigma)))))))

(define (eval-constante e)
  (lambda (rho)
    (lambda (sigma)
      (valeur (constante->n e)))))

(define (eval-identificateur e)
  (lambda (rho)
    (lambda (sigma)
      (sigma (rho e)))))

(define (valeur n)
  (cond ((compose? n) (valeur-compose n))
        ((simple? n)  (valeur-simple n))
        (else         (begin
                        (display "erreur : nombre inconnu : ")
                        (display n) (newline)))))

(define (valeur-compose n)
  (inEV (+ (* 10 (EV->int (valeur (compose->n n))))
           (EV->int (chiffre (compose->c n))))))

(define (valeur-simple n)
  (chiffre (simple->c n)))

(define (chiffre c)
  (cond ((equal? (chiffre->c c) 'zero)   (inEV 0))
        ((equal? (chiffre->c c) 'un)     (inEV 1))
        ((equal? (chiffre->c c) 'deux)   (inEV 2))
        ((equal? (chiffre->c c) 'trois)  (inEV 3))
        ((equal? (chiffre->c c) 'quatre) (inEV 4))
        ((equal? (chiffre->c c) 'cinq)   (inEV 5))
        ((equal? (chiffre->c c) 'six)    (inEV 6))
        ((equal? (chiffre->c c) 'sept)   (inEV 7))
        ((equal? (chiffre->c c) 'huit)   (inEV 8))
        ((equal? (chiffre->c c) 'neuf)   (inEV 9))
        (else (begin
                (display "erreur : chiffre inconnu : ")
                (display c) (newline)))))
