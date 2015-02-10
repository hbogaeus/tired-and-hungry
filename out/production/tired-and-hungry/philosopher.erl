-module(philosopher).
-author("Henry Bogaeus & Simon Carlson").

-define(SLEEP_BASE, 1000).
-define(SLEEP_MAX, 10000).
-define(EAT_TIME, 2000).
-define(TIMEOUT, 1000).

-export([start/5]).

start(Hungry, Left, Right, Name, Ctrl) ->
  spawn_link(fun() -> sleeping(Hungry, Left, Right, Name, Ctrl) end).

sleeping(0, _Left, _Right, Name, Ctrl) ->
  io:format("~s IS NO LONGER HUNGRY AND IS LEAVING!~n", [Name]),
  Ctrl ! done;
sleeping(Hungry, Left, Right, Name, Ctrl) ->
  io:format("~s is sleeping!~n", [Name]),
  Waiter = sleep(),
  eat(Left, Right, Waiter),

  sleeping(Hungry - 1, Left, Right, Name, Ctrl).

eat(Left, Right, Waiter) ->
  io:format("Eating with ~w and ~w ~n", [Left, Right]),
  chopstick:request(Left, self()),
  chopstick:request(Right, self()),
  receive
    {granted, _} ->
      receive
        {granted, _} ->
          ok
      end
  end,
  timer:sleep(?SLEEP_BASE),
  Waiter ! done,
  chopstick:return(Left),
  chopstick:return(Right).

sleep() ->
  receive
    {wake, Waiter} ->
      io:format("Woke up! ~n"),
      Waiter
  end.

% DROP A BOMB ON IT!