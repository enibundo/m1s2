%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%
% expressions
%%%%%%%%%%%%%%%%%%%%

% id
initialise(Id, Env):-member(Id, Env).


% exp*
initialise([HeadExp|TailExps], Env):- 
	initialise(HeadExp, Env),
	initialise(TailExps, Env).

% not
initialise(not(Exp), Env):-
	initialise(Exp, Env).

% methodCall
initialise(methodCall(Exp, Id, Exps), Env):-
	initialise(Exp, Env),
	initialise(Exps, Env).


%%%%%%%%%%%%%%%%%%%%
% instructions
%%%%%%%%%%%%%%%%%%%%

initialise(seq(Inst1, Inst2), EnvDebut, EnvRetour):-
	initialise(Inst1, EnvDebut, EnvRetour2),
	initialise(Inst2, EnvRetour2, EnvRetour).

% seq
initialise(seq(Inst1, Inst2), Env):-
	initialise

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
