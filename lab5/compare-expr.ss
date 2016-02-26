(define either_not_list
	(lambda (x y)
		(or (not (list? x)) (not (list? y)))
))

(define last_in_list
	(lambda (x y)
		(or (null? (cdr x)) (null? (cdr y)))
))

(define both_bools_unequal
	(lambda (a b)
		(and (boolean? a) (boolean? b) (not (equal? a b)))
))

(define bool_case
	(lambda (x y)
		(if x 'TCP '(not TCP))
))

(define base_case
	(lambda (x y outer_parens)
		(if (both_bools_unequal x y)
			(bool_case x y)	
			(if outer_parens
				`((if TCP ,x ,y))
				`(if TCP ,x ,y)
			)
		)
))

(define is_prefix
	(lambda (x y)
		(if (or (null? x) (null? y))
			#t
			(if (equal? (car x) (car y))
				(is_prefix (cdr x) (cdr y))
				#f
			)
		)
))

(define quote-prefix
	(lambda (x y)
		(or (equal? (car x) 'quote) (equal? (car y) 'quote))
))

(define if_mismatch
	(lambda (x y)
		(and (or (equal? (car x) 'if) (equal? (car y) 'if))
			(not (equal? (car x) (car y))) 
		)
))

(define diff_prefix
	(lambda (x y)
		(if (or (null? x) (null? y))
			(not (equal? x y))
			(if (equal? (car (car x)) (car (car y)))
				(diff_prefix (cdr x) (cdr y))
				#t
			)
		)	
))

(define let_mismatch
	(lambda (x y)
	(or ; one let and one non-let 
		(and (or (equal? (car x) 'let) (equal? (car y) 'let))
				(not (equal? (car x) (car y)))
		)
		(and 
			(and (equal? (car x) 'let) (equal? (car x) (car y)))
			(diff_prefix (car (cdr x)) (car (cdr y)))
		)
	)	
))

(define lambda_mismatch
	(lambda (x y)
		(or
			(and (or (equal? (car x) 'lambda) (equal? (car y) 'lambda))
				(not (equal? (car x) (car y)))
			)
			(and
				(and (equal? (car x) 'lambda) (equal? (car y) (car x)))
				(not (equal? (car (cdr x)) (car (cdr y))))
			)		
		)
))

(define compare-expr-helper
	(lambda (x y outer_parens)
	(if (equal? x y)
		x ; if equal, return one of the expressions
		( ; else if first elements aren't equal, then recurse
			if (or (either_not_list x y) (last_in_list x y) (is_prefix x y)
					(quote-prefix x y) (if_mismatch x y) (let_mismatch x y)
					(lambda_mismatch x y))
				(if (or (either_not_list x y) (is_prefix x y) 
						(quote-prefix x y) (if_mismatch x y)(let_mismatch x y)
						(lambda_mismatch x y))
							(base_case x y outer_parens)
					(if (either_not_list (car x) (car y)) 
						(base_case (car x) (car y) outer_parens) ; base case
						`(,(compare-expr-helper (car x) (car y) #f)) ; bc for nested lists
					)
				)
				(if (either_not_list (car x) (car y))
					(if (equal? (car x) (car y)) ; recurse based on equality of curr frag
						(cons (car x) (compare-expr-helper (cdr x) (cdr y) #t))
						(cons 
							(if (both_bools_unequal (car x) (car y))
								(bool_case (car x) (car y))	
								`(if TCP ,(car x) ,(car y)) 
							)
							(compare-expr-helper (cdr x) (cdr y) #t)
						)
					)
					; both heads are lists, so we recurse twice
					(cons (compare-expr-helper (car x) (car y) #f)
						(compare-expr-helper (cdr x) (cdr y) #t)
					)
				)
		)
	)
))

(define compare-expr
	(lambda (x y)
	(compare-expr-helper x y #f)
))

(define test-compare-expr
	(lambda (x y)
		(and (equal? (eval x) (eval `(let ((TCP #t)) ,(compare-expr x y))))
			 (equal? (eval y) (eval `(let ((TCP #f)) ,(compare-expr x y))))
		)
))

(define test-x '(cons (cons (cons (cons (cons (+ 2 (let ((a 1) (b 2)) (if #t (* a b) (- a b)))) ((lambda (x y) (+ x y)) 17 3)) (if #t 'a 'b)) (+ 1 2 3 4)) (cons (cons 'a 'b)
(cons 'c 'd))) ((lambda (h i) (* i h)) 43 232)))

(define test-y '(cons (cons (cons (cons (cons (cons (+ 100 (let ((a 5) (b 48)) (* a b))) 
	'(cons i j)) ((lambda (x y) (* x y)) 3 4)) (if #t 'a 'c)) (+ 1 2 3))
	(cons (cons 'a 'b) (cons 'c 'e))) ((lambda (h b) (- h b)) 23 -234)))
