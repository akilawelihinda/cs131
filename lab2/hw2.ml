type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal;;

let rec getruleslist nonterminal = function
	| [] -> []
	| (lhs,rhs)::t -> if lhs=nonterminal then rhs::(getruleslist nonterminal t) else getruleslist nonterminal t;;

let convert_grammar gram1 = 
	match gram1 with
	| (start, ruleslist) -> (start, fun nonterminal -> (getruleslist nonterminal ruleslist));;

let rec or_matcher currsymbol currsymbolrules getexpansions acceptor derivation fragment = 
	match currsymbolrules with
	| [] -> None (*no more possible rules left to match*)
	| h::t ->
			match (and_matcher h getexpansions acceptor (derivation@[currsymbol,h]) fragment) with (*try matching all the rhs symbols of this expansion*)
			| None -> or_matcher currsymbol t getexpansions acceptor derivation fragment (*if failed then try different expansion*)
			| returnval -> returnval (*if succeeded then return what and_matcher returned*)


and and_matcher curr_rule getexpansions acceptor derivation fragment = 
	match curr_rule with
	| [] -> acceptor derivation fragment (*no symbols left to match. return what acceptor returns*)
	| rulesleft ->
				  match fragment with
				  | [] -> None (*if fragment list used up and expansion isn't finished, then expansion is incorrect*)
				  | fragh::fragt -> (* otherwise we try to match current symbol from current rule expansion with token from fragment*)
									match rulesleft with
										(* If current rule is nonteriminal, then match it with all possible expansions using or_matcher*)
										(*Create a new acceptor that matches matches the rest of the current rule so the or_matcher knows what to look for*)
									| (N ruleh)::rulet -> (
															match (and_matcher rulet getexpansions acceptor) with
															| new_acceptor -> or_matcher ruleh (getexpansions ruleh) getexpansions new_acceptor derivation fragment
														  )
										(*If current rule is terminal, then we can compare fragment with current rule & attempt to expand rule further *)
									| (T ruleh)::rulet -> if ruleh=fragh then (and_matcher rulet getexpansions acceptor derivation fragt) else None
									| _ -> None;;


let parse_prefix gram acceptor fragment =
	match gram with
	| (start, getexpansions) -> or_matcher start (getexpansions start) getexpansions acceptor [] fragment;;
	
