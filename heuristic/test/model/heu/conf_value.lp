%stage_value= stage_length * turnrate   
max_phase_limit(stage(J,N),M) :- 
stage(J,N), 
M = #max{L : phase_limit(stage(J,N),_,L)}.

turn_in(J1,S,M) :- 
goal_count(link(J1,GL,J2),_),
S = stage(J1,_),
M = #sum{R,L2 : turnrate_gez(S,L2,link(J1,GL,J2),R)}.

exp_in(J1,S,E) :- 
turn_in(J1,S,M),
max_phase_limit(S,L),
E = M*L. 

max_stage_value(J1,C,S,M) :-
available_conf(_,C),
phase_limit(S,C,_),
exp_in(J1,S,_),
M = #max{N : exp_in(J1,S,N)}.

optimal_conf(J1,C,stage(J,N)) :- 
max_stage_value(J1,C,stage(J,N),_),
#count{C1 : max_stage_value(C1,stage(J,N),M)}=1. 

optimal_conf_empty(C,L) :- 
counter(0,link(J1,_,_),_),
optimal_conf(J1,C,S).

promising_conf_2(J,C,A) :- configuration(J,C,_,A), 
                           optimal_conf_empty(A,L).


%do the same thing for the outgoung link...

optimal_conf_fill(C,L) :- counter(0,L,_), 
                          stage_fill(S,L), 
                          optimal_conf(C,S).

promising_conf_1(J,C,A) :- configuration(J,C,_,A),
                           optimal_conf_fill(A,L).
