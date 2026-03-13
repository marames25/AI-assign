
% ========================
% TASK 1: Get a list of all books borrowed by a specific student

append([], List, List).
append([H|T], List, [H|List2]) :- append(T, List, List2).

books_borrowed_by_student(Student, L) :-
    collect(Student, [], L).

collect(Student, List, L) :-
    borrowed(Student, Book),
    \+ contains(Book, List),
    collect(Student, [Book|List], L).

collect(_, L, L).

contains(X, [X|_]).
contains(X, [_|T]) :- contains(X, T).

% ========================
% TASK 2: Count how many students borrowed a specific book

borrowers_count(Book, N) :-
    count_borrowers(Book, [], N),
    !.

count_borrowers(Book, Counted, N) :-
    \+ (borrowed(Student, Book), \+ member_manual(Student, Counted)),
    len_manual(Counted, N),
    !.

count_borrowers(Book, Counted, N) :-
    borrowed(Student, Book),
    \+ member_manual(Student, Counted),
    append_manual(Counted, [Student], NewCounted),
    count_borrowers(Book, NewCounted, N).

% ========================
% TASK Helper: Check membership
member_manual(X, [X|_]). % cheks the base case first and if it fails we proceed to the tail of the list
member_manual(X, [_|T]) :- % ignoring the first value as it is already compared in the base case
    member_manual(X, T).

% ========================
% TASK Helper: Append manually
append_manual([], [X], [X]).
append_manual([H|T], L2, [H|T2]) :- append_manual(T, L2, T2).

% ========================
% TASK Helper: List length
len_manual([], 0).
len_manual([_|T], N) :- len_manual(T, N1), N is N1 + 1.

% ========================
% TASK 3: Find the most borrowed book


most_borrowed_book(B) :-
    book(B,_),
    borrowers_count(B, N),
    max_book(B, N, B),
    !.

max_book(CurrentBook, CurrentMax, CurrentBook) :-
    \+ (book(OtherBook, _),
        borrowers_count(OtherBook, N2),
        N2 > CurrentMax).

% ========================
% TASK 4: List all ratings for a specific book

ratings_of_book(Book, L):-
    get_all_ratings(Book, [], Tmp), % extract all records in a list (Tmp)
    eliminate_book_record(Tmp, Result), % removes the books name
    L = Result.

get_all_ratings(Book, Acc, Result):-
    rating(Student, Book, Score), % reads the next record from the predicate
    \+ member_manual((Student, Book, Score), Acc), % reapeatdly checking if the record is already in the Acc and stops when all records are in Acc
    get_all_ratings(Book, [(Student, Book, Score) | Acc], Result). % appending record to Acc and recurce to the next call

get_all_ratings(_, Acc, Acc). % when the first rule fails, we uniform Result with Acc

% base case 
eliminate_book_record([(Student, _, Score)], Result):-
    Result = [(Student, Score)].

eliminate_book_record([(Student, _, Score) | Tail], Result):-
    eliminate_book_record(Tail, SR), Result = [(Student, Score) | SR]. % constructing Result from the previous result and the first head of the list


% ========================
% TASK 5: Find the top reviewer

get_all_scores(Acc, Result):-
    rating(_Student, _Book, Score), % reads the next record from the predicate
    \+ member_manual(Score, Acc), % reapeatdly checking if the record is already in the Acc and stops when all records are in Acc
    get_all_scores([Score | Acc], Result). % appending record to Acc and recurce to the next call

get_all_scores(L, L).

maximize(Head, [Head]). % the only element in a list is the max element

maximize(Mx, [Head | Tail]) :- 
    maximize(Nmx, Tail), % get the max of the Tail
    (Head > Nmx -> Mx = Head ; Mx = Nmx).

top_reviewer(Student):-
    get_all_scores([], Scores), % get all scores into a list
    maximize(Mx, Scores), % get the max of the list 
    rating(Student, _, Mx). % get the student who gave that score

% ========================
% TASK 6: Most common topic for a student


all_topics_of_books([], []).

all_topics_of_books([Book], Topics) :- topics(Book, Topics).

all_topics_of_books([Book|Tail], Result) :-
    topics(Book, T),
    append(T, Topics, Result),
    all_topics_of_books(Tail, Topics).

count(_, [], 0).
count(X, [X|T], N) :- count(X, T, N1), N is N1 + 1.
count(X, [_|T], N) :- count(X, T, N).

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

most_common_topic_for_student(Student, Topic) :-
    books_borrowed_by_student(Student, Books),
    all_topics_of_books(Books, Topics),
    most_repeated(Topics, Topic).