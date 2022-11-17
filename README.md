# Sudoku → Z3
`sudoku.scm` is a Scheme script that accepts a Sudoku board on `stdin` and
prints an [SMT 2](https://smtlib.cs.uiowa.edu/) program to `stdout`.

When the resulting program is run through a SAT/SMT solver, it will print the
solved board (or `unsat` if the board is invalid).

```console
$ cat example.txt
--3-2-6--
9--3-5--1
--18-64--
--81-29--
7-------8
--67-82--
--26-95--
8--2-3--9
--5-1-3--
$ guile sudoku.scm < example.txt > out.sat
$ z3 out.sat
sat
483921657
967345812
251876493
548132976
729564138
136798245
372619584
814253769
695487321
```

At the moment, this is only tested using
[Guile Scheme](https://www.gnu.org/software/guile/)
and the [Z3 Theorem Prover](https://github.com/Z3Prover/z3)
