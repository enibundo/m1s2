%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% return
hasReturn(return(Exp)).

% while exp inst
hasReturn(while(Exp, Inst)):- hasReturn(Inst).

% if(exp inst1 inst2)
hasReturn(if(Exp, Inst1, Inst2)):- 
	hasReturn(Inst1) ,
	hasReturn(Inst2).

% seq inst1 inst2
hasReturn(seq(Inst1, Inst2)):-
	hasReturn(Inst1).
hasReturn(seq(Inst1, Inst2)):-
	hasReturn(Inst2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%