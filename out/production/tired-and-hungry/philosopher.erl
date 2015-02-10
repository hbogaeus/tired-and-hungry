-module(philosopher).
-author("Henry").

-define(SLEEP_BASE, 1000).
-define(SLEEP_MAX, 10000).
-define(EAT_TIME, 2000).
-define(TIMEOUT, 1000).

-export([start/5, helloworld/0]).

start(Hungry, Left, Right, Name, Ctrl) ->
  spawn_link(fun() -> sleeping(Hungry, Left, Right, Name, Ctrl) end).

sleeping(0, _Left, _Right, Name, Ctrl) ->
  io:format("~s IS NO LONGER HUNGRY AND IS LEAVING!~n", [Name]),
  Ctrl ! done;
sleeping(Hungry, Left, Right, Name, Ctrl) ->
  Sleepytime = ?SLEEP_BASE + crypto:rand_uniform(0, ?SLEEP_MAX),
  io:format("~s is sleeping for ~w sec!~n", [Name, (Sleepytime / 1000)]),
  sleep(Sleepytime),

  case chopstick:granted(Left, Right, self(), ?TIMEOUT) of
    granted ->
      eat(?EAT_TIME, Left, Right, Name),
      sleeping(Hungry - 1, Left, Right, Name, Ctrl);
    not_granted ->
      sleeping(Hungry, Left, Right, Name, Ctrl)
  end.

eat(T, Left, Right, Name) ->
  io:format("~s is eating!~n", [Name]),
  timer:sleep(T),
  chopstick:return(Left),
  chopstick:return(Right).

sleep(Sleepytime) ->
  timer:sleep(Sleepytime).

helloworld() ->
  helloworldenden.