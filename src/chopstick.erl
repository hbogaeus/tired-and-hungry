-module(chopstick).
-author("Henry").

-compile(debug_info).

-export([start/1, granted/3, request/2, return/1, quit/1]).

start(Name) ->
  spawn_link(fun() -> available(Name) end).

available(Name) ->
  %io:format("~s is available!~n", [Name]),
  receive
    {request, From} ->
      From ! {granted, self()},
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

request(Stick, From) ->
  Stick ! {request, From}.

granted(Left, Right, Timeout) ->
  Self = self(),
  request(Left, Self),
  request(Right, Self),

  receive
    {granted, StickID1} ->
      receive
        {granted, _StickID2} ->
          granted
        after Timeout ->
          return(StickID1),
          not_granted
      end
  after Timeout ->
    not_granted
  end.

return(Stick) ->
  Stick ! return.

quit(Stick) ->
  Stick ! quit.