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
(define mask `((_ int2bv 9) ,#b111111111))
(define (bitor-block a b) (cons 'bvor (flatten bit a b)))
(define (assert-block a b) (display `(assert (= ,mask ,(bitor-block a b)))))
(define (assert-row row) (assert-block `(,row) (iota 9 1)))
(define (assert-col col) (assert-block (iota 9 1) `(,col)))
(define (assert-3x3 row col) (assert-block (iota 3 row) (iota 3 col)))
(map (lambda (i) (assert-row i) (assert-col i)) (iota 9 1))
(flatten assert-3x3 '(1 4 7) '(1 4 7))

; Read the board from stdin and apply constraints for existing digits
(define (assert-char row col)
  (define i (- (char->integer (read-char)) (char->integer #\1)))
  (when (and (>= i 1) (<= i 9))
    (display `(assert (= ,(sym row col) ((_ int2bv 9) ,i))))))
(flatten assert-char (iota 9 1) (iota 10 1)) ; (include a '\n' in column count)

(display '(check-sat)) ; Solve, then print the resulting board
(define (digit row col) `(* ,(expt 10 (- 9 col)) (+ 1 (bv2int ,(sym row col)))))
(define (print-row row)
  (display `(eval ,(cons '+ (map (lambda (col) (digit row col)) (iota 9 1))))))
(map print-row (iota 9 1))
