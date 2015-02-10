-module(chopstick).
-author("Henry Bogaeus & Simon Carlson").

-compile(debug_info).

-export([start/1, request/2, return/1, quit/1]).

start(Name) ->
  spawn_link(fun() -> available(Name) end).

available(Name) ->
  io:format("~s is available!~n", [Name]),
  receive
    {request, From} ->
      From ! {granted, self()},
      gone(Name);
    quit ->
      ok
  end.

gone(Name) ->
  io:format("~s is gone!~n", [Name]),
  receive
    return ->
      available(Name);
    quit ->
      ok;
    {request, _From} ->
      gone(Name)
  end.

request(Stick, From) ->
  Stick ! {request, From}.

return(Stick) ->
  Stick ! return.

quit(Stick) ->
  Stick ! quit.