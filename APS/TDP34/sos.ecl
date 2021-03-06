%*****************************************************************************
% 
% Semantique operationnelle structurelle de BOPL
%
% auteur :      (C) Jacques.Malenfant@lip6.fr
%
% cours :       MI030 - Analyse des programmes et sémantique
%
% date :        22 fevrier 2011
%
%*****************************************************************************

:- use_module(library(pretty_print)).
:- use_module(parser).

:- module(sos).
:- export evalFile/2, evalProgram/2, evalProgramTrace/2.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalFile/2
%
% evalFile(+FileName, -TypedAST)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalFile(FileName, Out) :-
  scanner:scan(FileName, Tokens),
  parser:parse(Tokens, AST),
  evalProgram(AST, Out),
  pretty_print:pretty_print(stdout, "\n", 80),
  pretty_print:pretty_print(stdout, Out, 80).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalProgram/2
% eval(+Program)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalProgram(program(Classes, Vars, Inst), Out) :-
  evalClasses(Classes, [],  E),
  evalVars(Vars, E, [], E1, S1),
  evalInst(Inst, E1, S1, [], _, Out).

evalProgramTrace(program(Classes, Vars, Inst), Out) :-
  evalClasses(Classes, [],  E),
  evalVars(Vars, E, [], E1, S1),
  evalInst(Inst, E1, S1, [], S2, Out),
  pretty_print:pretty_print(stdout, E1, 80),
  pretty_print:pretty_print(stdout, "\n", 80),
  pretty_print:pretty_print(stdout, S2, 80).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalClasses/3
% evalClasses(+Classes, +Env, -NewEnv)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalClasses([], E, E).
evalClasses([Class|Classes], E, NewE) :-
  evalClass(Class, E, E1),
  evalClasses(Classes, E1, NewE).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalClass/3
% evalClass(+ClassDef, +Env, -NewEnv)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalClass(class(Id, Cexp, Vars, Methods), E, NewE) :-
  evalCExp(Cexp, E, SuperId),
  getOwnedFields(SuperId, E, InheritedFields),
  append(Vars, InheritedFields, OwnedFields),
  evalMethods(Methods, Id, MethodDictionary),
  bind(Id, class(Id, SuperId, OwnedFields, MethodDictionary), E, NewE).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalMethods/3
% evalMethods(+Methods, +ClassId, -MethodDict)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalMethods([], _, []).
evalMethods([M|Ms], DefiningClassId, [MD|MDs]) :-
  evalMethod(M, DefiningClassId, MD),
  evalMethods(Ms, DefiningClassId, MDs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalMethod/3
% evalMethod(+Method, +ClassId, -MethodDictEntry)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalMethod(method(Id, FormalsDec, _, LocalsDec, Inst), DefiningClassId,
                      (Id, method(DefiningClassId, Formals, Locals, Inst))) :-
  extractIds(FormalsDec, Formals),
  extractIds(LocalsDec, Locals).

extractIds([], []).
extractIds([var(_, Id)|Vars], [Id|Ids]) :-
  extractIds(Vars, Ids).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalVars/5
% evalVars(+ListVars, +Env, +Store, -NewEnv, -NewStore)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalVars([], E, S, E, S).
evalVars([V|Vs], E, S, NewE, NewS) :-
  evalVar(V, E, S, E1, S1),
  evalVars(Vs, E1, S1, NewE, NewS).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalVar/5
% evalVar(+Var, +Env, +Store, -NewEnv, -NewStore)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalVar(var(_, Id), E, S, NewE, NewS) :-
  allocate(S, NewAddress, S1),
  bind(Id, NewAddress, E, NewE),
  writeStore(NewAddress, nil, S1, NewS).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalInst/6
% evalInst(+Inst, +Env, +Store, +Out,  -NewStore, -NewOut)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalInst(seq(Inst1, Inst2), E, S, O, NewS, NewO) :-
  evalInst(Inst1, E, S, O, S1, O1),
  evalInst(Inst2, E, S1, O1, NewS, NewO).

evalInst(if(BExp, Inst, _), E, S, O, NewS, NewO) :-
  evalExp(BExp, E, S, O, boolean(true), S1, O1),
  evalInst(Inst, E, S1, O1, NewS, NewO).
evalInst(if(BExp, _, Inst), E, S, O, NewS, NewO) :-
  evalExp(BExp, E, S, O, boolean(false), S1, O1),
  evalInst(Inst, E, S1, O1, NewS, NewO).

evalInst(while(BExp, Inst), E, S, O, NewS, NewO) :-
  evalExp(BExp, E, S, O, boolean(true), S1, O1),
  evalInst(Inst, E, S1, O1, S2, O2),
  evalInst(while(BExp, Inst), E, S2, O2, NewS, NewO).
evalInst(while(BExp, _), E, S, O, NewS, NewO) :-
  evalExp(BExp, E, S, O, boolean(false), NewS, NewO).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TP 4 eval pour le for 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalInst(for(Id, Exp1, Exp2, Exp3, Inst), E, S, O, NewS, NewO):-
  evalExp(Exp1, E, S, O, V1, S1, O1),
  evalExp(Exp2, E, S1, O1, V2, S2, O2), 
  evalExp(Exp3, E, S2, O2, V3, S3, O3),
  allocate(S3, NewAdress, S4),
  bind(Id, NewAdress, E, NewE),
  evalInstFor(V1, V2, V3, Inst, NewE, S4, O3, NewS, NewO).

evalInstFor(V1, V2, V3, Inst, E, S, O, A, NewS, NewO):-
  writeStore(A, V1, S, S1),
  evalInst(Inst, E, S1, O, S2, O1),
  evalInstFor(V, V2, V3, Inst, S2, O1, A, NewS, NewO),
  V is V1 + V3,
  V1 <= V2.

evalInstFor(V1, V2, V3, Inst, E, S, O, S, O):-
 V1 > V2. 

%%%%%%%%%%%%%%%%%
% fin for
%%%%%%%%%%%%%%%%


evalInst(assign(Id, Exp), E, S, O, NewS, NewO) :-
  lookup(Id, E, Address),
  evalExp(Exp, E, S, O, V, S1, NewO),
  writeStore(Address, V, S1, NewS).

evalInst(writeField(self, Id, Exp), E, S, O, NewS, NewO) :-
  lookup(id(self), E, Oid),
  evalExp(Exp, E, S, O, V, S1, NewO),
  writeField(Oid, Id, V, S1, NewS).
evalInst(writeField(super, Id, Exp), E, S, O, NewS, NewO) :-
  lookup(id(self), E, Oid),
  evalExp(Exp, E, S, O, V, S1, NewO),
  writeField(Oid, Id, V, S1, NewS).
evalInst(writeField(ExpRec, Id, Exp), E, S, O, NewS, NewO) :-
  not ExpRec = self,
  not ExpRec = super,
  evalExp(ExpRec, E, S, O, Oid, S1, O1),
  evalExp(Exp, E, S1, O1, V, S2, NewO),
  writeField(Oid, Id, V, S2, NewS).

evalInst(writeln(Exp), E, S, O, NewS, NewO) :-
  evalExp(Exp, E, S, O, V, NewS, O1),
  (addressOf(V, Address) ->
    readStore(Address, NewS, V1),
    term_string(V1, Printing)
  ; term_string(V, Printing)
  ),
  append(O1, [Printing], NewO).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalInstInMethod/7
% evalInstinMethod(+Inst, +Env, +Store, +Out, -Return, -NewStore, -NewOut)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalInstInMethod(seq(Inst1, Inst2), E, S, O, R, NewS, NewO) :-
  evalInstInMethod(Inst1, E, S, O, R, S1, O1),
  var(R),
  !,
  evalInstInMethod(Inst2, E, S1, O1, R, NewS, NewO).
evalInstInMethod(seq(Inst1, _), E, S, O, R, NewS, NewO) :-
  evalInstInMethod(Inst1, E, S, O, R, NewS, NewO),
  nonvar(R).

evalInstInMethod(if(BExp, Inst, _), E, S, O, R, NewS, NewO) :-
  evalExp(BExp, E, S, O, boolean(true), S1, O1),
  evalInstInMethod(Inst, E, S1, O1, R, NewS, NewO).
evalInstInMethod(if(BExp, _, Inst), E, S, O, R, NewS, NewO) :-
  evalExp(BExp, E, S, O, boolean(false), S1, O1),
  evalInstInMethod(Inst, E, S1, O1, R, NewS, NewO).

evalInstInMethod(while(BExp, Inst), E, S, O, R, NewS, NewO) :-
  evalExp(BExp, E, S, O, boolean(true), S1, O1),
  evalInstInMethod(Inst, E, S1, O1, R, S2, O2),
  var(R),
  !,
  evalInstInMethod(while(BExp, Inst), E, S2, O2, R, NewS, NewO).
evalInstInMethod(while(BExp, Inst), E, S, O, R, NewS, NewO) :-
  evalExp(BExp, E, S, O, boolean(true), S1, O1),
  evalInstInMethod(Inst, E, S1, O1, R, NewS, NewO),
  nonvar(R),
  !.
evalInstInMethod(while(BExp, _), E, S, O, _, NewS, NewO) :-
  evalExp(BExp, E, S, O, boolean(false), NewS, NewO).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TP 4 evalmethod pour le for
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A FINIR

evalInstInMethod(for(Id, Exp1, Exp2, Exp3, Inst), E, S, O, NewS, NewO):-
  evalExp(Exp1, E, S, O, V1, S1, O1),
  evalExp(Exp2, E, S1, O1, V2, S2, O2), 
  evalExp(Exp3, E, S2, O2, V3, S3, O3),
  allocate(S3, NewAdress, S4),
  bind(Id, NewAdress, E, NewE),
  evalInstForInMethod(V1, V2, V3, Inst, NewE, S4, O3, R, NewS, NewO),
  nonvar(R),
  !.

evalInstForInMethod(V1, V2, V3, Inst, E, S, O, A, R, NewS, NewO):-
  writeStore(A, V1, S, S1),
  evalInstInMethod(Inst, E, S1, O, R, S2, O1),
  evalInstForInMethod(V, V2, V3, Inst, S2, O1, A, R, NewS, NewO),
  V is V1 + V3,
  V1 <= V2.

evalInstForInMethod(V1, V2, V3, Inst, E, S, O, R, S, O):-
 V1 > V2. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fin for
%%%%%%%%%%%%%%%%%%%%%%%%%%%


evalInstInMethod(assign(Id, Exp), E, S, O, _, NewS, NewO) :-
  evalInst(assign(Id, Exp), E, S, O, NewS, NewO).

evalInstInMethod(writeField(ExpRec, Id, Exp), E, S, O, _, NewS, NewO) :-
  evalInst(writeField(ExpRec, Id, Exp), E, S, O, NewS, NewO).

evalInstInMethod(writeln(Exp), E, S, O, _, NewS, NewO) :-
  evalInst(writeln(Exp), E, S, O, NewS, NewO).

evalInstInMethod(return(Exp), E, S, O, R, NewS, NewO) :-
  evalExp(Exp, E, S, O, R, NewS, NewO).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalExp/7
% evalExp(+Exp, +Env, +Store, +Out, -Value, -NewStore, -NewOut)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalExp(int(N), _, S, O, integer(N), S, O).

evalExp(true, _, S, O, boolean(true), S, O).
evalExp(false, _, S, O, boolean(false), S, O).

evalExp(id(Name), E, S, O, V, S, O) :-
  lookup(id(Name), E, Address),
  readStore(Address, S, V).

evalExp(plus(Exp1, Exp2), E, S, O, integer(V), NewS, NewO) :-
  evalExp(Exp1, E, S, O, integer(V1), S1, O1),
  evalExp(Exp2, E, S1, O1, integer(V2), NewS, NewO),
  V is V1 + V2.

evalExp(minus(Exp1, Exp2), E, S, O, integer(V), NewS, NewO) :-
  evalExp(Exp1, E, S, O, integer(V1), S1, O1),
  evalExp(Exp2, E, S1, O1, integer(V2), NewS, NewO),
  V is V1 - V2.

evalExp(times(Exp1, Exp2), E, S, O, integer(V), NewS, NewO) :-
  evalExp(Exp1, E, S, O, integer(V1), S1, O1),
  evalExp(Exp2, E, S1, O1, integer(V2), NewS, NewO),
  V is V1 * V2.

evalExp(not(Exp), E, S, O, boolean(false), NewS, NewO) :-
  evalExp(Exp, E, S, O, boolean(true), NewS, NewO).
evalExp(not(Exp), E, S, O, boolean(true), NewS, NewO) :-
  evalExp(Exp, E, S, O, boolean(false), NewS, NewO).

evalExp(and(Exp1, Exp2), E, S, O, boolean(true), NewS, NewO) :-
  evalExp(Exp1, E, S, O, boolean(true), S1, O1),
  evalExp(Exp2, E, S1, O1, boolean(true), NewS, NewO).
evalExp(and(Exp1, Exp2), E, S, O, boolean(false), NewS, NewO) :-
  evalExp(Exp1, E, S, O, boolean(false), S1, O1),
  evalExp(Exp2, E, S1, O1, boolean(true), NewS, NewO).
evalExp(and(Exp1, Exp2), E, S, O, boolean(false), NewS, NewO) :-
  evalExp(Exp1, E, S, O, boolean(true), S1, O1),
  evalExp(Exp2, E, S1, O1, boolean(false), NewS, NewO).
evalExp(and(Exp1, Exp2), E, S, O, boolean(false), NewS, NewO) :-
  evalExp(Exp1, E, S, O, boolean(false), S1, O1),
  evalExp(Exp2, E, S1, O1, boolean(false), NewS, NewO).

evalExp(or(Exp1, Exp2), E, S, O, boolean(true), NewS, NewO) :-
  evalExp(Exp1, E, S, O, boolean(true), S1, O1),
  evalExp(Exp2, E, S1, O1, boolean(true), NewS, NewO).
evalExp(or(Exp1, Exp2), E, S, O, boolean(true), NewS, NewO) :-
  evalExp(Exp1, E, S, O, boolean(false), S1, O1),
  evalExp(Exp2, E, S1, O1, boolean(true), NewS, NewO).
evalExp(or(Exp1, Exp2), E, S, O, boolean(true), NewS, NewO) :-
  evalExp(Exp1, E, S, O, boolean(true), S1, O1),
  evalExp(Exp2, E, S1, O1, boolean(false), NewS, NewO).
evalExp(or(Exp1, Exp2), E, S, O, boolean(false), NewS, NewO) :-
  evalExp(Exp1, E, S, O, boolean(false), S1, O1),
  evalExp(Exp2, E, S1, O1, boolean(false), NewS, NewO).

evalExp(less(Exp1, Exp2), E, S, O, boolean(true), NewS, NewO) :-
  evalExp(Exp1, E, S, O, V1, S1, O1),
  evalExp(Exp2, E, S1, O1, V2, NewS, NewO),
  V1 < V2.
evalExp(less(Exp1, Exp2), E, S, O, boolean(false), NewS, NewO) :-
  evalExp(Exp1, E, S, O, V1, S1, O1),
  evalExp(Exp2, E, S1, O1, V2, NewS, NewO),
  V1 >= V2.

evalExp(equal(Exp1, Exp2), E, S, O, boolean(true), NewS, NewO) :-
  evalExp(Exp1, E, S, O, V1, S1, O1),
  evalExp(Exp2, E, S1, O1, V2, NewS, NewO),
  V1 = V2.
evalExp(equal(Exp1, Exp2), E, S, O, boolean(false), NewS, NewO) :-
  evalExp(Exp1, E, S, O, V1, S1, O1),
  evalExp(Exp2, E, S1, O1, V2, NewS, NewO),
  not V1 = V2.

evalExp(nil, _, S, O, nil, S, O).

evalExp(new(Cexp), E, S, O, Oid, NewS, O) :-
  evalCExp(Cexp, E, InstClassId),
  getOwnedFields(InstClassId, E, OwnedFields),
  allocateFields(OwnedFields, Fields),
  allocate(S, Address, S1),
  createOid(Address, Oid),
  writeStore(Address, object(Oid, InstClassId, Fields), S1, NewS).

evalExp(instanceof(Exp, Cexp), E, S, O, boolean(true), NewS, NewO) :-
  evalExp(Exp, E, S, O, oid(Address), NewS, NewO),
  readStore(Address, NewS, object(_, InstClassId, _)),
  evalCExp(Cexp, E, ClassId),
  inheritsFrom(InstClassId, ClassId, E).
evalExp(instanceof(Exp, Cexp), E, S, O, boolean(false), NewS, NewO) :-
  evalExp(Exp, E, S, O, oid(Address), NewS, NewO),
  readStore(Address, NewS, object(_, InstClassId, _)),
  evalCExp(Cexp, E, ClassId),
  not inheritsFrom(InstClassId, ClassId, E).

evalExp(methodcall(self, MethodId, Actuals), E, S, O, V, NewS, NewO) :-
  lookup(id(self), E, Oid),
  addressOf(Oid, Address),
  readStore(Address, S, object(Oid, ClassId, _)),
  lookForMethod(ClassId, MethodId, E,
                method(DefiningClassId, Formals, Locals, Body)),
  getSuper(DefiningClassId, E, SuperId),
  evalExpList(Actuals, E, S, O, Params, S1, O1),
  bind(id(super), SuperId, E, E1),
  storeAll(Formals, Params, E1, S1, E2, S2),
  allocateAll(Locals, E2, S2, E3, S3),
  evalInstInMethod(Body, E3, S3, O1, V, NewS, NewO).
evalExp(methodcall(super, MethodId, Actuals), E, S, O, V, NewS, NewO) :-
  lookup(id(super), E, SuperId),
  lookForMethod(SuperId, MethodId, E,
                method(DefiningClassId, Formals, Locals, Body)),
  getSuper(DefiningClassId, E, NewSuperId),
  evalExpList(Actuals, E, S, O, Params, S1, O1),
  bind(id(super), NewSuperId, E, E1),
  storeAll(Formals, Params, E1, S1, E2, S2),
  allocateAll(Locals, E2, S2, E3, S3),
  evalInstInMethod(Body, E3, S3, O1, V, NewS, NewO).
evalExp(methodcall(ExpRec, MethodId, Actuals), E, S, O, V, NewS, NewO) :-
  not ExpRec = self,
  not ExpRec = super,
  evalExp(ExpRec, E, S, O, Oid, S1, O1),
  addressOf(Oid, Address),
  readStore(Address, S1, object(oid(Address), ClassId, _)),
  lookForMethod(ClassId, MethodId, E,
                method(DefiningClassId, Formals, Locals, Body)),
  getSuper(DefiningClassId, E, NewSuperId),
  evalExpList(Actuals, E, S1, O1, Params, S2, O2),
  bind(id(self), oid(Address), E, E1),
  bind(id(super), NewSuperId, E1, E2),
  storeAll(Formals, Params, E2, S2, E3, S3),
  allocateAll(Locals, E3, S3, E4, S4),
  evalInstInMethod(Body, E4, S4, O2, V, NewS, NewO).

evalExp(readField(self, Id), E, S, O, V, S, O) :-
  lookup(id(self), E, Oid),
  addressOf(Oid, Address),
  readStore(Address, S, object(oid(Address), _, Fields)),
  readField(Fields, Id, V).
evalExp(readField(ExpRec, Id), E, S, O, V, NewS, NewO) :-
  not ExpRec = self,
  evalExp(ExpRec, E, S, O, Oid, NewS, NewO),
  addressOf(Oid, Address),
  readStore(Address, S, object(oid(Address), _, Fields)),
  readField(Fields, Id, V).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalCExp/3
% evalCExp(+CExp, +Env, -Value)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalCExp(cexp(Id), E, Id) :-
  isType(Id, E),
  !.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evalExpList/7
% evalExpList(+ListExp, +Env, +Store, +Out, -Values, -NewStore, -NewOut)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

evalExpList([], _, S, O, [], S, O).
evalExpList([Exp|ExpList], E, S, O, [V|Vs], NewS, NewO) :-
  evalExp(Exp, E, S, O, V, S1, O1),
  evalExpList(ExpList, E, S1, O1, Vs, NewS, NewO).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gestion des classes et des objets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% isType(+Id, +Environment)
isType(id('Object'), _).
isType(id('Int'), _).
isType(id('Bool'), _).
isType(id('Void'), _).
isType(Id, E) :-
  lookup(Id, E, class(_, _, _, _)).

getSuper(ClassId, E, SuperId) :-
  lookup(ClassId, E, class(ClassId, SuperId, _, _)).

getOwnedFields(id('Object'), _, []).
getOwnedFields(ClassId, E, OwnedFields) :-
  lookup(ClassId, E, class(ClassId, _, OwnedFields, _)).

allocateFields([], []).
allocateFields([var(_, Id)|OwnedFields], [(Id, nil)|Fields]) :-
  allocateFields(OwnedFields, Fields).

readField([], _, _) :-
  pretty_print:pretty_print(stderr, "not a field", 80),
  abort.
readField([(Id, V)|_], Id, V) :-
  !.
readField([_|Fields], Id, V) :-
  readField(Fields, Id, V).

writeField(Oid, Id, V, S, NewS) :-
  addressOf(Oid, Address),
  readStore(Address, S, object(Oid, DefiningClassId, Fields)),
  updateField(Id, Fields, V, NewFields),
  writeStore(Address,
             object(Oid, DefiningClassId, NewFields), S, NewS).

updateField(_, [], _, _) :-
  pretty_print:pretty_print(stderr, "no such field", 80),
  abort.
updateField(Id, [(Id, _)|Fields], V, [(Id,V)|Fields]).
updateField(Id, [(Other, Vo)|Fields], V, [(Other, Vo)|NewFields]) :-
  not Id = Other,
  updateField(Id, Fields, V, NewFields).

inheritsFrom(id('Object'), _, _) :-
  !,
  fail.
inheritsFrom(ClassId, SuperId, E) :-
  lookup(ClassId, E, class(ClassId, SuperId, _, _)).
inheritsFrom(ClassId, InheritedId, E) :-
  lookup(ClassId, E, class(ClassId, SuperId, _, _)),
  inheritsFrom(SuperId, InheritedId, E).

lookForMethod(ClassId, MethodId, E, Method) :-
  lookup(ClassId, E, class(ClassId, _, _, DeclaredMethods)),
  lookup(MethodId, DeclaredMethods, Method),
  !.
lookForMethod(ClassId, MethodId, E, Method) :-
  lookup(ClassId, E, class(ClassId, SuperId, _, _)),
  lookForMethod(SuperId, MethodId, E, Method).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gestion de l'environnement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% lookup(+Id, +Env, -Value)
lookup(Name, [(Name, Address)|_], Address) :-
  !.
lookup(Name, [_|Rest], Address) :-
  lookup(Name, Rest, Address).

% bind(+Id, +Value, +Env, -NewEnv)
bind(Id, V, E, [(Id, V)|E]).

% allocateAll(+Ids, +Env, +Store, -NewEnv, -NewStore)
allocateAll([], E, S, E, S).
allocateAll([Id|Ids], E, S, NewE, NewS) :-
  allocate(S, NewAddress, S1),
  bind(Id, NewAddress, E, E1),
  writeStore(NewAddress, nil, S1, S2),
  allocateAll(Ids, E1, S2, NewE, NewS).

% storeAll(+Ids, +Values, +Env, +Store, -NewEnv, -NewStore)
storeAll([], [], E, S, E, S).
storeAll([Id|Ids], [V|Vs], E, S, NewE, NewS) :-
  allocate(S, NewAddress, S1),
  bind(Id, NewAddress, E, E1),
  writeStore(NewAddress, V, S1, S2),
  storeAll(Ids, Vs, E1, S2, NewE, NewS).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gestion de la memoire
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

readStore(_, [], _) :-
  pretty_print:pretty_print(stderr, "unknown oid", 80),
  abort.
readStore(Address, [(Address, Value)|_], Value) :-
  !.
readStore(Address, [_|Rest], Value) :-
  readStore(Address, Rest, Value).

writeStore(Address, Value, [], [(Address, Value)]).
writeStore(Address, Value, [(Address, _)|Rest], [(Address, Value)|Rest]) :-
  !.
writeStore(Address, Value, [(Other, V)|Rest], [(Other, V)|NewS]) :-
  writeStore(Address, Value, Rest, NewS).

:- dynamic address/1.

address(0).

allocate(S, NewAddress, S) :-
  retract(address(Address)),
  NewAddress is Address + 1,
  asserta(address(NewAddress)).

createOid(Address, oid(Address)) :-
  address(Address).

addressOf(oid(Address), Address).
