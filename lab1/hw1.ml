type ('nonterminal, 'terminal) symbol =
	| N of 'nonterminal
	| T of 'terminal;;

let rec subset a b =
	match(a,b) with
	| [],_ -> true
	| _,[] -> false
	| [a1],[b1] -> if a1=b1 then true else false
	| ha::ta,hb::tb -> if (ha=hb || subset [ha] tb) && subset ta b then true else false;;

let equal_sets a b = subset a b && subset b a;;

let rec set_union a b = 
	match(a,b) with
	| [],[] -> []
	| [],_ -> b
	| _,[] -> a
	| [a1],[b1] -> if a1=b1 then [a1] else a1::[b1]
	| ha::ta,hb::tb -> if subset [ha] b then set_union ta b else  set_union ta (ha::b);;

let rec set_intersection a b =
	match(a,b) with
	| [],_ -> []
	| _,[] -> []
	| ha::ta,hb::tb -> if subset a b then a else if subset b a then b else 
		if subset [ha] b then set_intersection (ta@[ha]) b else 
		if subset [hb] a then set_intersection (tb@[hb]) a else set_intersection ta tb;;

let rec set_diff a b =
	match(a,b) with
	| [],_ -> []
	| _,[] -> a
	| ha::ta,hb::tb -> if subset [ha] b then set_diff ta b else [ha]@(set_diff ta b);;

let rec computed_fixed_point eq f x =
	if eq x (f x) then x else computed_fixed_point eq f (f x);;	

let rec computed_periodic_point eq f p x =
	match p with
	| 0 -> x
	| _ -> if (eq x (f(computed_periodic_point eq f (p-1) (f x)))) then x
		   else computed_periodic_point eq f p (f x);;

let is_rhs_good rhsrule terminal_rules = (*checks if one subrule of a rhsrule is good*)
	match rhsrule with
	| T r -> true
	| N r -> subset [r] terminal_rules;;

let rec is_entire_rhs_good rhsrules terminal_rules = (*checks if one entire rule is good*)
	match rhsrules with
	| [] ->  true
	| h::t -> if(is_rhs_good h terminal_rules && is_entire_rhs_good t terminal_rules) then true else false;;

let rec check_entire_grammar (rules,terminal_rules) =  (*gets all the terminal rules of an entire grammar in current iteration*)
	match rules with
	| [] -> terminal_rules
	| (lhs,rhs)::t -> if is_entire_rhs_good rhs terminal_rules && subset [lhs] terminal_rules = false 
						then check_entire_grammar (t, (lhs::terminal_rules)) 
					  else check_entire_grammar (t, terminal_rules);;

let rec get_all_terminal_rules (rules, terminalrules)= (*creates a list of all terminal rules*)
	if equal_sets terminalrules (check_entire_grammar (rules, terminalrules)) 
		then terminalrules 
	else get_all_terminal_rules (rules, check_entire_grammar(rules,terminalrules)) ;;

let rec remove_all_blind_alley_rules rules terminalrules= (*removes rule from grammar if not a terminal rule*)
	match rules with
	| [] -> []
	| (lhs,rhs)::t -> if is_entire_rhs_good rhs terminalrules 
						then (lhs,rhs)::remove_all_blind_alley_rules t terminalrules 
					  else remove_all_blind_alley_rules t terminalrules;;

let remove_all_blind_alley_rules_caller rules = (*simple helper function*)
	remove_all_blind_alley_rules rules (get_all_terminal_rules(rules,[]));;

let filter_blind_alleys g = 
	match g with
	| (start,startrules) -> (start, remove_all_blind_alley_rules_caller startrules);;
