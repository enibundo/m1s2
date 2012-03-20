max_list([X], X).
max_list([X|Y], Max):- max_list(Y, Max2), (X>=Max2, Max=X; Max=Max2).

delete_elem(D, [E], X):- E=D, X=[].
delete_elem(D, [E], X):- E\=D, X=[E].
delete_elem(D, [H|T], X):- H=D, delete_elem(D, T, X2), X=X2.
delete_elem(D, [H|T], X):- H\=D, delete_elem(D, T, X2), X=[H|X2].


%insert_elem(E, [], X):- X=[E].
%insert_elem(E, [H|T], X):- X=[E|[H|T]], insert_elem(E, 