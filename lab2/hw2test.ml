type awksub_nonterminals =
  | Expr | Lvalue | Incrop | Binop | Num

let awksub_rules =
   [Expr, [T"("; N Expr; T")"];
    Expr, [N Num];
    Expr, [N Expr; N Binop; N Expr];
    Expr, [N Lvalue];
    Expr, [N Incrop; N Lvalue];
    Expr, [N Lvalue; N Incrop];
    Lvalue, [T"$"; N Expr];
    Incrop, [T"++"];
    Incrop, [T"--"];
    Binop, [T"+"];
    Binop, [T"-"];
    Num, [T"0"];
    Num, [T"1"];
    Num, [T"2"];
    Num, [T"3"];
    Num, [T"4"];
    Num, [T"5"];
    Num, [T"6"];
    Num, [T"7"];
    Num, [T"8"];
    Num, [T"9"]]

let awksub_grammar = Expr, awksub_rules

type giant_nonterminals =
  | Conversation | Sentence | Grunt | Snore | Shout | Quiet

let giant_grammar =
  Conversation,
  [Snore, [T"ZZZ"];
   Quiet, [];
   Grunt, [T"khrgh"];
   Shout, [T"aooogah!"];
   Sentence, [N Quiet];
   Sentence, [N Grunt];
   Sentence, [N Shout];
   Conversation, [N Snore];
   Conversation, [N Sentence; T","; N Conversation]]

let awksub_grammar_hw2version = convert_grammar awksub_grammar

let giant_grammar_hw2version = convert_grammar giant_grammar

let convert_grammar_test0 = (snd awksub_grammar_hw2version Expr) = [[T"("; N Expr; T")"];[N Num];[N Expr; N Binop; N Expr];
																	[N Lvalue];[N Incrop; N Lvalue];[N Lvalue; N Incrop];]
let convert_grammar_test1 = (snd awksub_grammar_hw2version Lvalue) = [[T"$"; N Expr];]
let convert_grammar_test2 = (snd awksub_grammar_hw2version Incrop) = [[T"++"];[T"--"];]
let convert_grammar_test3 = (snd awksub_grammar_hw2version Binop) = [[T"+"];[T"-"];]
let convert_grammar_test4 = (snd awksub_grammar_hw2version Num) = [[T"0"];[T"1"];[T"2"];[T"3"];[T"4"];[T"5"];[T"6"];[T"7"];[T"8"];[T"9"]]

let convert_grammar_test5 = (snd giant_grammar_hw2version Snore) = [[T"ZZZ"]]
let convert_grammar_test6 = (snd giant_grammar_hw2version Quiet) = [[]]
let convert_grammar_test7 = (snd giant_grammar_hw2version Grunt) = [[T"khrgh"]]
let convert_grammar_test8 = (snd giant_grammar_hw2version Shout) = [[T"aooogah!"]]
let convert_grammar_test9 = (snd giant_grammar_hw2version Sentence) = [[N Quiet];[N Grunt];[N Shout];]
let convert_grammar_test10 = (snd giant_grammar_hw2version Conversation) = [[N Snore];[N Sentence; T","; N Conversation]]



(*Below are tests for parse_prefix*)
let accept_all derivation string = Some (derivation, string)
let accept_empty_suffix derivation = function
   | [] -> Some (derivation, [])
   | _ -> None


type basic_lang_terminals = 
	Paragraph | Sentence | Word | Noun | Verb

(*My invented grammar, which I realize is not complete, but serves the purpose of testing*)
let very_simple_lang_grammar = 
	Paragraph,
	[Paragraph, [N Sentence];
	Paragraph, [N Sentence; N Paragraph];
	Sentence, [N Word];
	Sentence, [N Word; N Sentence];
	Word, [N Noun];
	Word, [N Verb];
	Noun, [T "He"];
	Noun, [T "I"];
	Verb, [T "ran"];
	Verb, [T "biked"]]

let very_simple_lang_grammar_hw2version = convert_grammar very_simple_lang_grammar

let test_1 = parse_prefix awksub_grammar_hw2version accept_empty_suffix ["9"; "+";  "("; "0"; "+"; "1"; ")"] = Some
   ([(Expr, [N Expr; N Binop; N Expr]); (Expr, [N Num]); (Num, [T "9"]);
     (Binop, [T "+"]); (Expr, [T "("; N Expr; T ")"]);
     (Expr, [N Expr; N Binop; N Expr]); (Expr, [N Num]); (Num, [T "0"]);
     (Binop, [T "+"]); (Expr, [N Num]); (Num, [T "1"])],
    [])

let test_2 = parse_prefix very_simple_lang_grammar_hw2version accept_empty_suffix ["I"; "biked"] = Some
   ([(Paragraph, [N Sentence]); (Sentence, [N Word; N Sentence]);
	 (Word, [N Noun]); (Noun, [T "I"]); (Sentence, [N Word]);
	 (Word, [N Verb]); (Verb, [T "biked"])],
	[])
