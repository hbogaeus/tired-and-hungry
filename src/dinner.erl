-module(dinner).
-author("Henry").

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
  philosopher:start(3, C1, C2, "Platon", Ctrl),
  philosopher:start(3, C2, C3, "Nietzsche", Ctrl),
  philosopher:start(3, C3, C4, "Kant", Ctrl),
  philosopher:start(3, C4, C5, "Aristoteles", Ctrl),
  philosopher:start(3, C5, C1, "Sokrates", Ctrl),
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
