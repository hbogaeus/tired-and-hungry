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

  Left_Request = spawn_link(fun() -> chopstick:request(Left, self(), ?TIMEOUT_LEFT) end),
  Right_Request = spawn_link(fun() -> chopstick:request(Right, self(), ?TIMEOUT_RIGHT) end),

  receive
    {ok, _} ->
      receive
        {ok, _} ->
          eat(?EAT_TIME, Left, Right),
          sleeping(Hungry - 1, Left, Right, Name, Ctrl)
      end
  end.

eat(T, Left, Right) ->
  timer:sleep(T),
  chopstick:return(Left),
  chopstick:return(Right).

sleep(Sleepytime) ->
  timer:sleep(Sleepytime).