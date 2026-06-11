;;; -*- mode: lisp-data -*-
;; typst-ts-mode tempel templates — migrated from VSCode Hypersnips typst.hsnips
;; Expand: type trigger + TAB (or enable `tempel-abbrev-mode' for space expansion).

typst-ts-mode

;; --- block elements ---
(snot "#sidenote[" p "]" q :doc "sidenote")
(snon "#sidenote(numbered: false)[" p "]" q :doc "unnumbered sidenote")
(wbk "#wideblock[" p "]" q :doc "wideblock")

;; --- math: delimiters & spacing ---
(lm "$" p "$" :doc "inline math")
(dm "$ " p " $" :doc "display math")
(pp "(" p ")" :doc "parentheses")
(sr "^2" :doc "square")
(tp "^(" (p "3") ")" :doc "power")
(root "root(" (p "3") ", " r ")" :doc "root")
(fra "frac(" r ", " p ")" :doc "fraction")
(eva "evaluated(" r ")_" p :doc "evaluate")

;; --- math: single-operand functions ---
(abs "abs(" r ")" :doc "absolute value")
(sqrt "sqrt(" r ")" :doc "sqrt")
(circle "circle(" r ")" :doc "circle")

;; --- math: operators (bare) ---
(sum "sum " :doc "summation")
(int "integral " :doc "integral")
(pro "product " :doc "product")

;; --- math: operators (bounded) ---
(suma "sum_(" (p "i") " = " (p "1") ")^" (p "n") " " r :doc "summation bounded")
(inta "integral_" (p "a") "^" (p "b") " " r " dif " (p "x") :doc "integral bounded")
(proa "product_(" (p "k") " = " (p "1") ")^" (p "n") " " r :doc "product bounded")

;; --- math: differentials ---
(dd "dif" :doc "differential")
(dx "dif x" :doc "dif x")
(dy "dif y" :doc "dif y")
(dt "dif t" :doc "dif t")
(du "dif u" :doc "dif u")
(dv "dif v" :doc "dif v")
(dz "dif z" :doc "dif z")

;; --- math: partials ---
(par "partial " :doc "partial")
(parx "partial x" :doc "partial x")
(pary "partial y" :doc "partial y")
(part "partial t" :doc "partial t")
(paru "partial u" :doc "partial u")
(parv "partial v" :doc "partial v")
(parz "partial z" :doc "partial z")

;; --- math: arrows (trigger: ar + letter) ---
(arr "→" :doc "arrow →")
(arR "⇒" :doc "arrow ⇒")
(arl "←" :doc "arrow ←")
(arL "⇐" :doc "arrow ⇐")
(arB "⇔" :doc "arrow ⇔")

;; --- math: limit notation (trigger: lx + suffix) ---
(lx0 "lim_(x → 0)" :doc "limit x→0")
(lxi "lim_(x → oo)" :doc "limit x→∞")
(lx+ "lim_(x → +oo)" :doc "limit x→+∞")
(lx- "lim_(x → -oo)" :doc "limit x→-∞")
(lxx "lim_(x → x_0)" :doc "limit x→x₀")

;; --- math: cases (trigger: caseN / cassN) ---
(case2 "cases(" n> p "," n> p "," n ")" :doc "cases 2 rows")
(case3 "cases(" n> p "," n> p "," n> p "," n ")" :doc "cases 3 rows")
(case4 "cases(" n> p "," n> p "," n> p "," n> p "," n ")" :doc "cases 4 rows")
(case5 "cases(" n> p "," n> p "," n> p "," n> p "," n> p "," n ")" :doc "cases 5 rows")
(cass2 "cases(" n> (p "expr") "\\, space & " (p "cond") "," n> (p "expr") "\\, space & " (p "cond") "," n ")" :doc "cases w/ cond 2")
(cass3 "cases(" n> (p "expr") "\\, space & " (p "cond") "," n> (p "expr") "\\, space & " (p "cond") "," n> (p "expr") "\\, space & " (p "cond") "," n ")" :doc "cases w/ cond 3")
(cass4 "cases(" n> (p "expr") "\\, space & " (p "cond") "," n> (p "expr") "\\, space & " (p "cond") "," n> (p "expr") "\\, space & " (p "cond") "," n> (p "expr") "\\, space & " (p "cond") "," n ")" :doc "cases w/ cond 4")
(cass5 "cases(" n> (p "expr") "\\, space & " (p "cond") "," n> (p "expr") "\\, space & " (p "cond") "," n> (p "expr") "\\, space & " (p "cond") "," n> (p "expr") "\\, space & " (p "cond") "," n> (p "expr") "\\, space & " (p "cond") "," n ")" :doc "cases w/ cond 5")

;; Local Variables:
;; mode: lisp-data
;; outline-regexp: "[a-z]"
;; End:
