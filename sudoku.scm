(define (run f rows cols) ; Maps a function across two lists
  (let recurse ((rs rows) (cs cols))
    (cond ((null? rs) '())
          ((null? cs) (recurse (cdr rs) cols))
          (else (cons (f (car rs) (car cs)) (recurse rs (cdr cs)))))))

(define (sym row col) (string->symbol (format #f "v~A~A" row col)))
(define (assert-char row col) ; Read the board from stdin and declare consts
  (define i (- (char->integer (read-char)) (char->integer #\0)))
  (define s (sym row col))
  (display `(declare-const ,s Int))
  (display `(assert (and (>= ,s 1) (<= ,s 9))))
  (when (and (>= i 1) (<= i 9)) (display `(assert (= ,s ,i)))))
(run assert-char (iota 9 1) (iota 10 1)) ; (include a '\n' in column count)

(define (assert-block a b) (display `(assert (distinct ,@(run sym a b)))))
(define (assert-row row) (assert-block `(,row) (iota 9 1)))
(define (assert-col col) (assert-block (iota 9 1) `(,col)))
(define (assert-3x3 row col) (assert-block (iota 3 row) (iota 3 col)))
(map (lambda (i) (assert-row i) (assert-col i)) (iota 9 1))
(run assert-3x3 '(1 4 7) '(1 4 7))

(display `(check-sat)) ; Solve, then print the resulting board
(define (digit row col) `(* ,(expt 10 (- 9 col)) ,(sym row col)))
(define (print-row row)
  (display `(eval (+ ,@(map (lambda (col) (digit row col)) (iota 9 1))))))
(map print-row (iota 9 1))
