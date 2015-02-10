-module(chopstick).
-author("Henry").

-compile(debug_info).

-export([start/1, request/4, return/1, quit/1]).

start(Name) ->
  spawn_link(fun() -> available(Name) end).

available(Name) ->
  %io:format("~s is available!~n", [Name]),
  receive
    {request, From} ->
      From ! granted,
      gone(Name);
    quit ->
      ok
  end.

gone(Name) ->
  %io:format("~s is gone!~n", [Name]),
  receive
    return ->
      available(Name);
    quit ->
      ok
  end.

request(Left, Right, From, Timeout) ->
  Left ! {request, self()},
  Right ! {request, self()},
  receive
    granted ->
      receive
        granted ->
          From ! granted
      after Timeout ->
        From ! not_granted
      end
  after Timeout ->
    From ! not_granted
  end.

return(Stick) ->
  Stick ! return.

quit(Stick) ->
  Stick ! quit.