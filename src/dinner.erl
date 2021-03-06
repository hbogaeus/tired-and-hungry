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
  philosopher:start(3, C1, C2, "Platon", Ctrl), %Platon
  philosopher:start(3, C2, C3, "Nietzsche", Ctrl), %Nietzsche
  philosopher:start(3, C3, C4, "Kant", Ctrl), %Kant
  philosopher:start(3, C4, C5, "Aristoteles", Ctrl), %Aristoteles
  philosopher:start(3, C5, C1, "Sokrates", Ctrl), %Sokrates
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
