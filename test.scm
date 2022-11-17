(define (sym row col) (string->symbol (format #f "v~A~A" row col)))
(define (bit row col) `(bvshl ((_ int2bv 9) 1) ,(sym row col)))

(define (flatten f rows cols) ; Maps a function across two lists
  (let recurse ((rs rows) (cs cols))
    (cond ((null? rs) '())
          ((null? cs) (recurse (cdr rs) cols))
          (else (cons (f (car rs) (car cs)) (recurse rs (cdr cs)))))))

;; Declare our 9x9 variables
(define (declare-var row col)
  (display `(declare-const ,(sym row col) (_ BitVec 9))))
(flatten declare-var (iota 9 1) (iota 9 1))

;; Apply block-level constraints
(define (assert-block a b)
  (display `(assert (= ((_ int2bv 9) 511) ,(cons 'bvor (flatten bit a b))))))
(map (lambda (i) (assert-block (list i) (iota 9 1))
                 (assert-block (iota 9 1) (list i)))
     (iota 9 1))
(flatten (lambda (row col) (assert-block (iota 3 row) (iota 3 col)))
  '(1 4 7) '(1 4 7))

(flatten ; Read the board from stdin and apply additional constraints
  (lambda (row col)
    (let ((i (- (char->integer (read-char)) (char->integer #\1))))
      (when (and (>= i 1) (<= i 9))
        (display `(assert (= ,(sym row col) ((_ int2bv 9) ,i)))))))
  (iota 9 1) (iota 10 1)) ; (include a '\n' in column count)

(display '(check-sat)) ; Solve, then print the resulting board
(define (digit row col)
  `(* ,(expt 10 (- 9 col)) (+ 1 (bv2int ,(sym row col)))))
(define (print-row row)
  (display `(eval ,(cons '+ (map (lambda (col) (digit row col)) (iota 9 1))))))
(map print-row (iota 9 1))
