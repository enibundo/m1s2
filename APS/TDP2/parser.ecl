%*****************************************************************************
% 
% Analyseur syntaxique de BOPL
%
% auteur :      (C) Jacques.Malenfant@lip6.fr
%
% cours :       MI030 - Analyse des programmes et sémantique
%
% date :        16 janvier 2012
%
%*****************************************************************************

%*****************************************************************************
% Concrete grammar
%
% Program    ::= program ClassList Locals Seq
% Locals     ::= <epsilon> | let Vars in
% ClassList  ::= <epsilon> | Classes
% Classes    ::= Class | Classes Class
% Class      ::= class id Extends is VarList MethodList end
% Extends    ::= <epsilon> | extends Classexp
% Classexp   ::= Int | Bool | Void | Object | id
% VarList    ::= <epsilon> | vars Vars
% Vars       ::= Var | Vars Var
% Var        ::= Classexp Ids ;
% Ids        ::= id | Ids , id
% MethodList ::= <epsilon> | methods Methods
% Methods    ::= Method | Methods Method
% Method     ::= Classexp id ( FormalList ) Locals Seq
% FormalList ::= epsilon | Formals
% Formals    ::= Formal | Formals , Formal
% Formal     ::= Classexp id
% Seq        ::= begin Insts end
% Insts      ::= Inst | Insts ; Inst
% Inst       ::= id := Exp | Exp . id := Exp | return Exp |
%                if Exp then Seq else Seq | while Exp do Seq |
%                writeln ( Exp )
% Exp        ::= Exp . id | Exp . id ( ActualList ) | Exp instanceof Classexp |
%                Exp + Term | Exp - Term | Exp or Term | Term
% Term       ::= Term * Fact | Term and Fact | Fact
% Fact       ::= Fact = Basic | Fact < Basic | Basic
% Basic      ::= not Exp | int | id | true | false | nil | self | super |
%                new Classexp | ( Exp )
% ActualList ::= epsilon | Actuals
% Actuals    ::= Exp | Actuals , Exp
%*****************************************************************************

%*****************************************************************************
% Abstract syntax
%
% program ::= program(class*, var*, inst)
% class   ::= class(id, cexp, var*, method*)
% cexp    ::= cexp(id)
% var     ::= var(cexp, id)
% method  ::= method(id, var*, cexp, var*, inst)
% inst    ::= seq(inst, inst) | assign(id, exp) | writeField(exp, id, exp) |
%             if(exp, inst, inst) | while(exp, inst) | return(exp) |
%             writeln(Exp)
% exp     ::= int(N) | boolean(true) | boolean(false) | not(exp) | nil | self |
%             super | new(cexp) | instanceof(exp, cexp) | id |
%             methodcall(exp, id, exp*) | readField(exp, id) |id(Atom) |
%             plus(exp, exp) | minus(exp, exp) | times(exp, exp) |
%             equal(exp, exp) | and(exp, exp) | or(exp, exp) | less(exp, exp)
%*****************************************************************************

:- use_module(library(pretty_print)).
:- use_module(scanner).

:- module(parser).
:- export parseFile/2, parse/2.

% parseFile(+FileName, -AST)
parseFile(FileName, AST) :-
  scanner:scan(FileName, Tokens),
  parse(Tokens, AST),
  pretty_print:pretty_print(stdout, AST, 80).


% parse(+Tokens, -AST)
parse(Tokens, AST) :-
  program(Tokens, AST, []).

%parseToken(+Read, ?Expected)
parseToken(Read, Expected) :-
  nonvar(Read),
  Read = Expected.

% program(+Tokens, ?AST, -RestTokens)
program([T|Ts], program(Classes, Vars, Inst), []) :-
  parseToken(T, program),
  classlist(Ts, Classes, RTs),
  locals(RTs, Vars, RTs1),
  seq(RTs1, Inst, []).

% locals(+Tokens, ?AST, -RestTokens)
locals([T|Tokens], Vars, RestTokens) :-
  parseToken(T, let),
  !,
  vars(Tokens, Vars, [RT|RestTokens]),
  parseToken(RT, in).
locals(Tokens, [], Tokens).

% classlist(+Tokens, ?AST, -RestTokens)
% TODO : classlist et classes tous les deux utiles ?
classlist(Tokens, Classes, RestTokens) :-
  classes(Tokens, Classes, RestTokens),
  !.
classlist(Tokens, [], Tokens).

% classes(+Tokens, ?AST, -RestTokens)
classes(Tokens, [Class|Classes], RestTokens) :-
  class(Tokens, Class, RTs),
  !,
  classes(RTs, Classes, RestTokens).
classes(Tokens, [], Tokens).

% class(+Tokens, ?AST, -RestTokens)
class([T|Tokens], class(Id, Super, Vars, Methods), RestTokens) :-
  parseToken(T, class),
  id(Tokens, Id, RTs1),
  extends(RTs1, Super, [RT2|RTs2]),
  parseToken(RT2, is),
  varlist(RTs2, Vars, RTs3),
  methodlist(RTs3, Methods, [RT4|RestTokens]),
  parseToken(RT4, end).

% extends(+Tokens, ?Ast, -RestTokens)
extends([T|Tokens], Super, RestTokens) :-
  (  parseToken(T, extends),
     !,
     classexp(Tokens, Super, RestTokens)
  ;  Super = cexp(id('Object')),
     RestTokens = [T|Tokens]
  ).

% classexp(+Tokens, ?AST, -RestTokens)
classexp([T|RestTokens], cexp(id('Int')), RestTokens) :-
  parseToken(T, 'Int'),
  !.
classexp([T|RestTokens], cexp(id('Bool')), RestTokens) :-
  parseToken(T, 'Bool'),
  !.
classexp([T|RestTokens], cexp(id('Void')), RestTokens) :-
  parseToken(T, 'Void'),
  !.
classexp([T|RestTokens], cexp(id('Object')), RestTokens) :-
  parseToken(T, 'Object'),
  !.
classexp(Tokens, cexp(Id), RestTokens) :-
  id(Tokens, Id, RestTokens).

% varlist(+Tokens, ?AST, -RestTokens)
varlist([T|Tokens], Vars, RestTokens) :-
  parseToken(T, vars),
  !,
  vars(Tokens, Vars, RestTokens).
varlist(Tokens, [], Tokens).

% vars(+Tokens, ?AST, -RestTokens)
vars(Tokens, Vars, RestTokens) :-
  var(Tokens, Vs1, RTs),
  !,
  vars(RTs, Vs2, RestTokens),
  append(Vs1, Vs2, Vars).
vars(Tokens, [], Tokens).

% var(+Tokens, ?AST, -RestTokens)
var(Tokens, Vars, RestTokens) :-
  classexp(Tokens, C, RTs),
  ids(RTs, C, Vars, [RT2|RestTokens]),
  parseToken(RT2, semicolon).

% ids(+Tokens, +Classexp, ?AST, -RestTokens)
ids(Tokens, Classexp, [var(Classexp, Id)|Vars], RestTokens) :-
  id(Tokens, Id, [RT|RTs]),
  parseToken(RT, comma),
  !,
  ids(RTs, Classexp, Vars, RestTokens).
ids(Tokens, Classexp, [var(Classexp, Id)], RestTokens) :-
  id(Tokens, Id, RestTokens).

% methodlist(+Tokens, ?AST, -RestTokens)
methodlist([T|Tokens], Methods, RestTokens) :-
  parseToken(T, methods),
  !,
  methods(Tokens, Methods, RestTokens).
methodlist(Tokens, [], Tokens).

% methods(+Tokens, ?AST, -RestTokens)
methods(Tokens, [M|Methods], RestTokens) :-
  method(Tokens, M, RTs),
  !,
  methods(RTs, Methods, RestTokens).
methods(Tokens, [], Tokens).

% method(+Tokens, ?AST, -RestTokens)
method(Tokens, method(Id, Formals, ReturnType, Vars, Inst), RestTokens) :-
  classexp(Tokens, ReturnType, RTs1),
  id(RTs1, Id, [RT2|RTs2]),
  parseToken(RT2, lparen),
  formallist(RTs2, Formals, [RT3|RTs3]),
  parseToken(RT3, rparen),
  locals(RTs3, Vars, RTs4),
  seq(RTs4, Inst, RestTokens).

% formallist(+Tokens, ?AST, -RestTokens)
formallist(Tokens, Formals, RestTokens) :-
  formals(Tokens, Formals, RestTokens),
  !.
formallist(Tokens, [], Tokens).

% formals(+Tokens, ?AST, -RestTokens)
formals(Tokens, [F|Formals], RestTokens) :-
  formal(Tokens, F, [RT|RTs]),
  parseToken(RT, comma),
  !,
  formals(RTs, Formals, RestTokens).
formals(Tokens, [F], RestTokens) :-
  formal(Tokens, F, RestTokens).

% formal(+Tokens, ?AST, -RestTokens)
formal(Tokens, var(Classexp, Id), RestTokens) :-
  classexp(Tokens, Classexp, RTs),
  id(RTs, Id, RestTokens).

% seq(+Tokens, ?AST, -RestTokens)
seq([T|Tokens], Inst, RestTokens) :-
  parseToken(T, begin),
  insts(Tokens, Inst, [RT1|RestTokens]),
  parseToken(RT1, end).

% insts(+Tokens, ?Ast, -RestTokens)
% recursivite a droite plutot qu'a gauche pour la descente recursive...
insts(Tokens, seq(Inst1, Inst2), RestTokens) :-
  inst(Tokens, Inst1, [RT1|RTs1]),
  parseToken(RT1, semicolon),
  !,
  insts(RTs1, Inst2, RestTokens).
insts(Tokens, Inst, RestTokens) :-
  inst(Tokens, Inst, RestTokens).

% inst(+Tokens, ?AST, -RestTokens)
inst(Tokens, assign(Id, Exp), RestTokens) :-
  id(Tokens, Id, [RT|RTs]),
  parseToken(RT, assign),
  !,
  exp(RTs, Exp, RestTokens).
inst(Tokens, writeField(ExpRec, Id, Exp), RestTokens) :-
  exp(Tokens, ExpRec, [RT|RTs]),
  parseToken(RT, period),
  id(RTs, Id, [RT1|RTs1]),
  parseToken(RT1, assign),
  !,
  exp(RTs1, Exp, RestTokens).
inst([T|Tokens], return(Exp), RestTokens) :-
  parseToken(T, return),
  !,
  exp(Tokens, Exp, RestTokens).
inst([T|Tokens], if(BExp, InstThen, InstElse), RestTokens) :-
  parseToken(T, if),
  !,
  exp(Tokens, BExp, [RT1|RTs1]),
  parseToken(RT1, then),
  seq(RTs1, InstThen, [RT2|RTs2]),
  parseToken(RT2, else),
  seq(RTs2, InstElse, RestTokens).
inst([T|Tokens], while(BExp, Inst), RestTokens) :-
  parseToken(T, while),
  !,
  exp(Tokens, BExp, [RT1|RTs1]),
  parseToken(RT1, do),
  seq(RTs1, Inst, RestTokens).
inst([T, T1|Tokens], writeln(Exp), RestTokens) :-
  parseToken(T, writeln),
  !,
  parseToken(T1, lparen),
  exp(Tokens, Exp, [RT|RestTokens]),
  parseToken(RT, rparen).


% exp(+Tokens, ?AST, -RestTokens)
exp(Tokens, Exp, RestTokens) :-
  term(Tokens, Term, RTs),
  expprime(RTs, Term, Exp, RestTokens).

% expprime(+Tokens, +AST, ?NewAST, -RestTokens)
expprime([T|Tokens], Left, Exp, RestTokens) :-
  parseToken(T, period),
  id(Tokens, Id, [RT|RTs]),
  parseToken(RT, lparen),
  !,
  actuallist(RTs, Actuals, [RT2|RTs2]),
  parseToken(RT2, rparen),
  expprime(RTs2, methodcall(Left, Id, Actuals), Exp, RestTokens).
expprime([T|Tokens], Left, Exp, RestTokens) :-
  parseToken(T, period),
  id(Tokens, Id, RTs),
  (  RTs = [RT|_],           % prevision pour ne pas se tromper avec
     parseToken(RT, assign)  % writeField
     ->
     fail
  ;  true
  ),
  !,
  expprime(RTs, readField(Left, Id), Exp, RestTokens).
expprime([T|Tokens], Left, Exp, RestTokens) :-
  parseToken(T, instanceof),
  !,
  classexp(Tokens, Classexp, RTs),
  expprime(RTs, instanceof(Left, Classexp), Exp, RestTokens).
expprime([T|Tokens], Left, Exp, RestTokens) :-
  parseToken(T, plus),
  !,
  exp(Tokens, Exp1, RTs),
  expprime(RTs, plus(Left, Exp1), Exp, RestTokens).
expprime([T|Tokens], Left, Exp, RestTokens) :-
  parseToken(T, minus),
  !,
  exp(Tokens, Exp1, RTs),
  expprime(RTs, minus(Left, Exp1), Exp, RestTokens).
expprime([T|Tokens], Left, Exp, RestTokens) :-
  parseToken(T, or),
  !,
  exp(Tokens, Exp1, RTs),
  expprime(RTs, or(Left, Exp1), Exp, RestTokens).
expprime(Tokens, Left, Left, Tokens).

% term(+Tokens, ?AST, -RestTokens)
term(Tokens, Term, RestTokens) :-
  fact(Tokens, Fact, RTs),
  termprime(RTs, Fact, Term, RestTokens),
  !.
term(Tokens, Fact, RestTokens) :-
  fact(Tokens, Fact, RestTokens).

% termprime(+Tokens, +AST, ?NewAST, -RestTokens)
termprime([T|Tokens], Left, Term, RestTokens) :-
  parseToken(T, times),
  !,
  term(Tokens, Term1, RTs),
  termprime(RTs, times(Left, Term1), Term, RestTokens).
termprime([T|Tokens], Left, Term, RestTokens) :-
  parseToken(T, and),
  !,
  term(Tokens, Term1, RTs),
  termprime(RTs, and(Left, Term1), Term, RestTokens).
termprime(Tokens, Left, Left, Tokens).

% fact(+Tokens, ?AST, -RestTokens)
fact(Tokens, Fact, RestTokens) :-
  basic(Tokens, Basic, RTs),
  factprime(RTs, Basic, Fact, RestTokens),
  !.
fact(Tokens, Fact, RestTokens) :-
  basic(Tokens, Fact, RestTokens).

% factprime(+Tokens, +AST, ?NewAST, -RestTokens)
factprime([T|Tokens], Left, Fact, RestTokens) :-
  parseToken(T, equal),
  !,
  basic(Tokens, Fact1, RTs),
  factprime(RTs, equal(Left, Fact1), Fact, RestTokens).
factprime([T|Tokens], Left, Fact, RestTokens) :-
  parseToken(T, less),
  !,
  basic(Tokens, Fact1, RTs),
  factprime(RTs, equal(Left, Fact1), Fact, RestTokens).
factprime(Tokens, Left, Left, Tokens).

% basic(+Tokens, ?AST, -RestTokens)
basic([T|Tokens], nil, Tokens) :-
  parseToken(T, nil),
  !.
basic([T|Tokens], true, Tokens) :-
  parseToken(T, true),
  !.
basic([T|Tokens], false, Tokens) :-
  parseToken(T, false),
  !.
basic([T|Tokens], self, Tokens) :-
  parseToken(T, self),
  !.
basic([T|Tokens], super, Tokens) :-
  parseToken(T, super),
  !.
basic([T|Tokens], new(C), RestTokens) :-
  parseToken(T, new),
  !,
  classexp(Tokens, C, RestTokens).
basic([T|Tokens], not(Exp), RestTokens) :-
  parseToken(T, not),
  !,
  exp(Tokens, Exp, RestTokens).
basic(Tokens, id(N), RestTokens) :-
  id(Tokens, id(N), RestTokens),
  !.
basic([T|Tokens], int(T), Tokens) :-
  integer(T),
  !.
basic([T|Tokens], Exp, RestTokens) :-
  parseToken(T, lparen),
  exp(Tokens, Exp, [RT|RestTokens]),
  parseToken(RT, rparen).

% actuallist(+Tokens, ?AST, -RestTokens)
actuallist(Tokens, Actuals, RestTokens) :-
  actuals(Tokens, Actuals, RestTokens),
  !.
actuallist(Tokens, [], Tokens).

% actuals(+Tokens, ?AST, -RestTokens)
actuals(Tokens, [R|Actuals], RestTokens) :-
  exp(Tokens, R, [RT|RTs]),
  parseToken(RT, comma),
  !,
  actuals(RTs, Actuals, RestTokens).
actuals(Tokens, [R], RestTokens) :-
  exp(Tokens, R, RestTokens).

% id(+Tokens, ?AST, -RestTokens)
id([T|Tokens], id(N), Tokens) :-
  parseToken(T, id(N)).