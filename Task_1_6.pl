append([],List,List).

append([H|T] , List , [H|List2]):-
    append(T,List,List2).



books_borrowed_by_student(Student, L) :-
    collect(Student, [] , L).

collect(Student, List, L) :-
    borrowed(Student, Book),
    \+ contains(Book, List),
    collect(Student, [Book|List], L).

collect(_, L, L).

contains(X, [X|_]).
contains(X, [_|T]) :-
    contains(X, T).


all_topics_of_books([],[]).


all_topics_of_books([Book],Topics):-
    topics(Book,Topics).

all_topics_of_books([Book|Tail],Result):-
    topics(Book,T),
    append(T,Topics,Result),
    all_topics_of_books(Tail,Topics).

count(_, [], 0).

count(X, [X|T], N) :-
    count(X, T, N1),
    N is N1 + 1.

count(X, [_|T], N) :-
    count(X, T, N).


most_repeated([H|T], Result) :-
    count(H, [H|T], Count),
    most_repeated(T, H, Count, Result).


most_repeated([], Topic, _, Topic).

most_repeated([H|T], CurrentTopic, CurrentCount, Result) :-
    count(H, [H|T], Count),
    Count > CurrentCount,
    most_repeated(T, H, Count, Result).

most_repeated([H|T], CurrentTopic, CurrentCount, Result) :-
    count(H, [H|T], Count),
    Count =< CurrentCount,
    most_repeated(T, CurrentTopic, CurrentCount, Result).

most_common_topic_for_student(Student, Topic):-
    books_borrowed_by_student(Student,Books),
    all_topics_of_books(Books,Topics),
    most_repeated(Topics,Topic).
