-module(philosopher).
-author("Henry").

-define(SLEEP_BASE, 1000).
-define(SLEEP_MAX, 10000).
-define(EAT_TIME, 2000).
-define(TIMEOUT_LEFT, 1000).
-define(TIMEOUT_RIGHT, 2000).

-export([start/5]).

start(Hungry, Left, Right, Name, Ctrl) ->
  spawn_link(fun() -> sleeping(Hungry, Left, Right, Name, Ctrl) end).

sleeping(0, _Left, _Right, Name, Ctrl) ->
  io:format("~s IS NO LONGER HUNGRY AND IS LEAVING!~n", [Name]),
  Ctrl ! done;
sleeping(Hungry, Left, Right, Name, Ctrl) ->
  Sleepytime = ?SLEEP_BASE + crypto:rand_uniform(0, ?SLEEP_MAX),
  io:format("~s is sleeping for ~w sec!~n", [Name, (Sleepytime / 1000)]),
  sleep(Sleepytime),

  A = spawn_link(fun() -> chopstick:request(Left, ?TIMEOUT_LEFT) end),
  B = spawn_link(fun() -> chopstick:request(Right, ?TIMEOUT_RIGHT) end),

  case {A, B} of
    {ok, ok} ->
      eat(?EAT_TIME, Left, Right),
      sleeping(Hungry - 1, Left, Right, Name, Ctrl);
    {ok, _} ->
      chopstick:return(Left),
      sleeping(Hungry, Left, Right, Name, Ctrl);
    {_, ok} ->
      chopstick:return(Right),
      sleeping(Hungry, Left, Right, Name, Ctrl);
    {_, _} ->
      sleeping(Hungry, Left, Right, Name, Ctrl)
  end.

eat(T, Left, Right) ->
  timer:sleep(T),
  chopstick:return(Left),
  chopstick:return(Right).

sleep(Sleepytime) ->
  timer:sleep(Sleepytime).