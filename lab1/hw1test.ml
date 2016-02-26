let my_subtest_test0=subset [3;4;5;5;5;5;5;5;5;3;4;] [3;4;3;4;5];;
let my_subtest_test1=subset [1;2;3;] [1;2;3;];;
let my_subtest_test2=subset [] [1;2;3;4;4;4;45;];;
let my_subtest_test3=subset [1;2;3] [] = false;;

let my_equal_sets_test0=equal_sets [1;2;3;] [3;2;1;1;1;2;3;2;];;
let my_equal_sets_test1=equal_sets [1;2;3;4;] [3;2;1;1;1;2;3;2;] = false;;
let my_equal_sets_test2=equal_sets [] [];;
let my_equal_sets_test3=equal_sets [1] [1];;
let my_equal_sets_test4=equal_sets [1] [1;1;1;1;1;1;1;];;

let my_set_union_test0= equal_sets (set_union [8;1;2;3;] [1;3;2;4;1;1;6;]) [8;1;2;3;4;6];;
let my_set_union_test1=equal_sets (set_union [1;3;2;4;5;6;4;] [7;1;2;]) [1;3;2;4;5;6;7;];;
let my_set_union_test2=equal_sets (set_union [] []) [];;
let my_set_union_test3=equal_sets (set_union [1;] []) [1;];;
let my_set_union_test4=equal_sets (set_union [1;1;1;1;1;] [1;2;3;4;]) [1;2;3;4;];;
let my_set_union_test5=equal_sets (set_union [] [1;]) [1;];;

let my_set_intersection_test0=equal_sets (set_intersection [1;2;] []) [];;
let my_set_intersection_test1=equal_sets (set_intersection [1;2;3] [3;]) [3;];;
let my_set_intersection_test2=equal_sets (set_intersection [1;3;2;4;5;6;4;] [7;1;2;]) [1;2;];;
let my_set_intersection_test3=equal_sets (set_intersection [1;3;4;5;6;4;8;2;] [1;7;2;3;]) [1;2;3;];;
let my_set_intersection_test4=equal_sets (set_intersection [1;7;2;3;] [1;3;4;5;6;4;8;2;]) [1;2;3;];;

let my_set_diff_test0=equal_sets (set_diff [1;2;3;] [4;5;6;8;3;]) [1;2;];;
let my_set_diff_test1=equal_sets (set_diff [1;2;3;3;4;5;] [1;2;3;4;4;43;1;]) [5;];;
let my_set_diff_test2=equal_sets (set_diff [1;2;3;] [1;2;3;]) [];;
let my_set_diff_test3=equal_sets (set_diff [] [1;2;3;]) [];;
let my_set_diff_test4=equal_sets (set_diff [1;2;3;] []) [1;2;3;];;

let my_computed_fixed_point0=computed_fixed_point (=) (fun x -> x / 2) 1000000000 = 0;;
let my_computed_fixed_point1=computed_fixed_point (=) (fun x -> if x>100 then 369 else x+1) 0 = 369;;
let my_computed_fixed_point2=computed_fixed_point (=) (fun x -> if x<=0 then 0 else x-1) 30 = 0;;

let my_computed_periodic_point_test0=computed_periodic_point (=) (fun x -> x / 2) 0 (-1) = -1;;
let my_computed_periodic_point_test1=computed_periodic_point (=) (fun x -> if x>10 then 100 else x+1) 1 (5) = 100;;
let my_computed_periodic_point_test2=computed_periodic_point (=) (fun x -> if x>10 then 30 else x+1) 10 (5) = 30;;

type awksub_nonterminals =
  | Expr | Lvalue | Incrop | Binop | Num;;

let akila_rules =
    [Expr, [N Num];
    Lvalue, [T"$"; N Expr];
    Incrop, [T"++"];
    Incrop, [T"--"];
    Binop, [T"+"];
    Binop, [T"-"];
    Num, [T"0"];];;

let my_filter_blind_alleys0 = (filter_blind_alleys (Expr, akila_rules)) = (Expr,akila_rules);;

let akila_rules1 =
    [Lvalue, [T"$"; N Expr];
    Incrop, [T"++"];
    Incrop, [T"--"];
    Binop, [T"+"];
    Binop, [T"-"];
    Num, [T"0"];];;

let my_filter_blind_alleys1 = (filter_blind_alleys (Expr, akila_rules1)) = (Expr,
    [Incrop, [T"++"];Incrop, [T"--"];Binop, [T"+"];Binop, [T"-"];Num, [T"0"];]);;
