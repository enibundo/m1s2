%*******************************************************************************
% 
% Semantique de BOPL
%
% auteur :      (C) Jacques.Malenfant@lip6.fr
%
% cours :       MI030 - Analyse des programmes et sémantique
%
% date :        22 fevrier 2011
%
%*******************************************************************************

:- use_module(library(pretty_print)).
:- [scanner,parser,typeChecker,sos].

:- module(bopl).
:- export exec/1, execWTC/1, execTrace/1, typeCheck/1, typeCheckTrace/1.

exec(FileName) :-
  scanner:scan(FileName, Tokens),
  parser:parse(Tokens,AST),
  typeChecker:typeCheckProgram(AST, _),
  sos:evalProgram(AST, Res),
  printRes(Res).

execWTC(FileName) :-
  scanner:scan(FileName, Tokens),
  parser:parse(Tokens,AST),
  sos:evalProgram(AST, Res),
  printRes(Res).

execTrace(FileName) :-
  scanner:scan(FileName, Tokens),
  %viewTokens(Tokens),
  parser:parse(Tokens,AST),
  pretty_print:pretty_print(stdout, AST, 80),
  typeChecker:typeCheckProgram(AST, TypedAST),
  pretty_print:pretty_print(stdout, TypedAST, 80),
  sos:evalProgram(AST, Res),
  printRes(Res).

viewTokens([]).
viewTokens([T|Ts]) :-
  write(T),
  nl,
  viewTokens(Ts).

printRes(R) :- write("[\n"), printResRec(R), write("]").

printResRec([]).
printResRec([R|Rs]) :-
  write(" "), writeq(R), write("\n"), printResRec(Rs).

typeCheck(FileName) :-
  scanner:scan(FileName, Tokens),
  parser:parse(Tokens,AST),
  typeChecker:typeCheckProgram(AST, TypedAST),
  pretty_print:pretty_print(stdout, TypedAST, 80).

typeCheckTrace(FileName) :-
  scanner:scan(FileName, Tokens),
  %viewTokens(Tokens),
  parser:parse(Tokens,AST),
  pretty_print:pretty_print(stdout, AST, 80),
  typeChecker:typeCheckProgram(AST, TypedAST),
  pretty_print:pretty_print(stdout, TypedAST, 80).
