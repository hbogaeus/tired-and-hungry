-module(dinner).
-author("Henry Bogaeus & Simon Carlson").

-export([start/0]).

start () ->
  spawn(fun() -> init() end).

init() ->
  C1 = chopstick:start("C1"),
  C2 = chopstick:start("C2"),
  C3 = chopstick:start("C3"),
  C4 = chopstick:start("C4"),
  C5 = chopstick:start("C5"),
  Ctrl = self(),
  P1 = philosopher:start(3, C1, C2, "Platon", Ctrl), %Platon
  P2 = philosopher:start(3, C2, C3, "Nietzsche", Ctrl), %Nietzsche
  P3 = philosopher:start(3, C3, C4, "Kant", Ctrl), %Kant
  P4 = philosopher:start(3, C4, C5, "Aristoteles", Ctrl), %Aristoteles
  P5 = philosopher:start(3, C5, C1, "Sokrates", Ctrl), %Sokrates
  waiter:start({P1, P2, P3, P4, P5}),
  wait(5, [C1, C2, C3, C4, C5]).

wait(0, Chopsticks) ->
  lists:foreach(fun(C) -> chopstick:quit(C) end, Chopsticks),
  io:format("Dinner is over, table is empty!~n");
wait(N, Chopsticks) ->
  receive
    done ->
      wait(N - 1, Chopsticks);
    abort ->
      exit(abort)
  end.
