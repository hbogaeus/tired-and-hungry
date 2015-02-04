-module(chopstick).
-author("Henry").

-compile(debug_info).

-export([start/1, request/3, return/1, quit/1]).

start(Name) ->
  spawn_link(fun() -> available(Name) end).

available(Name) ->
  io:format("~s is available!~n", [Name]),
  receive
    {request, From} ->
      From ! granted,
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
      ok
  end.

request(Stick, From, Timeout) ->
  Stick ! {request, self()},
  receive
    granted ->
      From ! {ok, self()}
  after Timeout ->
    From ! {no, self()}
  end.

return(Stick) ->
  Stick ! return.

quit(Stick) ->
  Stick ! quit.