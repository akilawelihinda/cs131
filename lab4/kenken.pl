% KEN-KEN SOLVER
% My Finite Domain Ken-Ken solver completed a 6x6 puzzle in less than 1 millisecond.
% My Plain Ken-Ken solver completed a 4x4 puzzle in ~1 second.

% GNU Prolog doesn't have transpose, so here is the implementation of transpose
% taken from the following StackOverflow link:
%     http://stackoverflow.com/questions/4280986/how-to-transpose-a-matrix-in-prolog
% This poster claims that this transpose code is a slightly modified version of the
% SWI-Prolog transpose implementation, which is located in the link below:
%	  https://github.com/lamby/pkg-swi-prolog/blob/master/library/clp/clpfd.pl
% I checked the user's claim, and it appears to be correct.
% Please note that this implementation of transpose is NOT mine.
transpose([], []).
transpose([F|Fs], Ts) :-
	transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
	lists_firsts_rests(Ms, Ts, Ms1),
	transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
	lists_firsts_rests(Rest, Fs, Oss).

% Part 1: FINITE DOMAIN KEN-KEN IMPLEMENTATION
satrc(N,T):- fd_domain(T,1,N).
checkLen(N,T1):-length(T1,N).
checkLens(T,N):-length(T,N),maplist(checkLen(N),T).
getval(I-J,T,Val):-nth(I,T,Row),nth(J,Row,Val).

add(_,[],0).
add(Mat,[H|T],Sum):-getval(H,Mat,Val),add(Mat,T,Prev_sum),Sum#=Prev_sum+Val.
mult(_,[],1).
mult(Mat,[H|T],Prod):-getval(H,Mat,Val),mult(Mat,T,Prev_prod),Prod#=Prev_prod*Val.
mat_con(N,T,+(S, L)):-add(T,L,Sum), S #= Sum.
mat_con(N,T,*(P, L)):-mult(T,L,Prod), P #= Prod.
mat_con(N,T,-(D, J, K)):-getval(J,T,Jval),getval(K,T,Kval),(D #= Jval-Kval;
	D #= Kval-Jval).
mat_con(N,T,/(Q, J, K)):-getval(J,T,Jval),getval(K,T,Kval),(Kval #\= 0),(Jval #\= 0),
	(Q*Kval #= Jval ; Q*Jval #=Kval).
kenken(N,C,T):-checkLens(T,N),maplist(satrc(N),T),maplist(fd_all_different,T),
	transpose(T,Trans),maplist(fd_all_different,Trans),maplist(mat_con(N,T), C),
	maplist(fd_labeling,T).

% Part 2: PLAIN KEN-KEN
mult_p(_,[],1).
mult_p(M,[H|T],Prod):-getval(H,M,Hval),mult_p(M,T,Tailprod),Prod is Tailprod*Hval.
add_p(_,[],0).
add_p(M,[H|T],Sum):-getval(H,M,Hval),add_p(M,T,Tailsum),Sum is Tailsum+Hval.
cleandiv(X,Y,Q):- (0 =:= X rem Y, Q is X // Y);(0 =:= Y rem X, Q is Y // X).
diffrows(_,[]).
diffrows(N,[H|T]):- \+member(H,T),diffrows(N,T).
in_range(N,Lo,X):-X is Lo ; (N>Lo,in_range(N,Lo+1,X)).
satrc_p(N,R):-maplist(in_range(N,1),R),diffrows(N,R).
mat_conp(N,T,+(S, L)):-add_p(T,L,Sum), S is Sum.
mat_conp(N,T,*(P, L)):-mult_p(T,L,Prod), S is Prod.
mat_conp(N,T,-(D,J,K)):-getval(J,T,Jval),getval(K,T,Kval),(D is Kval-Jval;D is Jval-Kval).
mat_conp(N,T,/(Q, J, K)):-getval(J,T,Jval),getval(K,T,Kval),cleandiv(Kval,Jval,Q). 
plain_kenken(N,C,T):-checkLens(T,N),maplist(satrc_p(N),T),transpose(T,Trans),
	maplist(satrc_p(N),Trans),maplist(mat_conp(N,T),C).
