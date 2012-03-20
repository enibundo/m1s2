%*******************************************************************************
% 
% Analyseur lexical de BOPL
%
% auteur :      (C) Jacques.Malenfant@lip6.fr
%
% cours :       MI030 - Analyse des programmes et sémantique
%
% date :        22 fevrier 2011
%
%*******************************************************************************

:- use_module(library(pretty_print)).
:- module(scanner).
:- export scanFile/2, scan/2.

scanFile(FileName, Tokens) :-
  scan(FileName, Tokens),
  pretty_print:pretty_print(stdout, Tokens, 80).


scan(FileName, Tokens) :-
  open(FileName, read, IS),
  get(IS, Char),
  scanTokens(IS, Char, Tokens),
  pretty_print:pretty_print(stdout, "\n", 80),
  close(IS).

scanTokens(_, C, []) :-
  isEos(C),
  !.
scanTokens(IS, C, Tokens) :-
  scanToken(IS, C, Token, NextC),
  pretty_print:pretty_print(stdout, Token, 80),
  pretty_print:pretty_print(stdout, " ", 80),
  (Token = eof ->
     Tokens = RestTokens
  ;  Tokens = [Token | RestTokens]
  ),
  scanTokens(IS, NextC, RestTokens).

isDigit(C) :- C >= 48, C =< 57.
isLower(C) :- C >= 97, C =< 122.
isUpper(C) :- C >= 65, C =< 90.
isEos(C) :- endfile(C).

endfile(26).
endfile(-1).
endline(10).
space(32).
tab(9).
period(46).
lparen(40).
rparen(41).
times(42).
plus(43).
comma(44).
minus(45).
colon(58).
semicolon(59).
less(60).
equal(61).

scanToken(IS, C, Token, NextC) :-
  ( isDigit(C), !, getInt(IS, C, Token, NextC)
  ; (isLower(C) ; isUpper(C)),
    !,
    getId(IS, C, Id, NextC),
    ( reservedWord(Id), !, Token = Id
    ; Token = id(Id)
    )
  ; (space(C) ; tab(C) ; endline(C)),
    !,
    get(IS, Char), scanToken(IS, Char, Token, NextC)
  ; isEos(C), !, Token = eof, NextC = C
  ; period(C), !, Token = period, get(IS, NextC)
  ; lparen(C), !, Token = lparen, get(IS, NextC)
  ; rparen(C), !, Token = rparen, get(IS, NextC)
  ; times(C), !, Token = times, get(IS, NextC)
  ; plus(C), !, Token = plus, get(IS, NextC)
  ; comma(C), !, Token = comma, get(IS, NextC)
  ; minus(C), !, Token = minus, get(IS, NextC)
  ; colon(C), !, get(IS, Eq), equal(Eq), Token = assign, get(IS, NextC)
  ; semicolon(C), !, Token = semicolon, get(IS, NextC)
  ; less(C), !, Token = less, get(IS, NextC)
  ; equal(C), !, Token = equal, get(IS, NextC)
  ).

reservedWord(program).
reservedWord(begin).
reservedWord(let).
reservedWord(in).
reservedWord(end).
reservedWord(class).
reservedWord(is).
reservedWord(extends).
reservedWord(vars).
reservedWord(methods).
reservedWord(if).
reservedWord(then).
reservedWord(else).
reservedWord(while).
reservedWord(do).
reservedWord(return).
reservedWord(writeln).
reservedWord(nil).
reservedWord(self).
reservedWord(super).
reservedWord(new).
reservedWord(or).
reservedWord(and).
reservedWord(not).
reservedWord(instanceof).
reservedWord(true).
reservedWord(false).
reservedWord('Int').
reservedWord('Bool').
reservedWord('Void').
reservedWord('Object').


getId(IS, C, Id, NextC) :-
  (isUpper(C) ; isLower(C)),
  get(IS, Char),
  restId(IS, Char, Lc, NextC),
  string_list(Idstring, [C|Lc]),
  atom_string(Id, Idstring).

restId(IS, C, [C|L], NextC) :-
  (isUpper(C) ; isLower(C) ; isDigit(C) ; C = '_'),
  !,
  get(IS, Char),
  restId(IS, Char, L, NextC).
restId(_, NextC, [], NextC).

getInt(IS, C, N, NextC) :-
  isDigit(C),
  get(IS, Char),
  restInt(IS, Char, Lc, NextC),
  string_list(Numstring, [C|Lc]),
  number_string(N, Numstring).

restInt(IS, C, [C|L], NextC) :-
  isDigit(C),
  !,
  get(IS, Char),
  restInt(IS, Char, L, NextC).
restInt(_, NextC, [], NextC).