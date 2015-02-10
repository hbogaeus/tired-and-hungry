-module(chopstick).
-author("Henry").

-compile(debug_info).

-export([start/1, request/3, granted/4, return/1, quit/1]).

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
      From ! {ok, Stick}
  after Timeout ->
    From ! {no, Stick}
  end.

granted(Left, Right, From, Timeout) ->
  Self = self(),
  spawn_link(fun() -> chopstick:request(Left, Self, Timeout) end),
  spawn_link(fun() -> chopstick:request(Right, Self, Timeout) end),

  receive
    {ok, _} ->
      receive
        {ok, _} ->
          From ! granted;
        {no, Left} ->
          return(Right),
          From ! not_granted;
        {no, Right} ->
          return(Left),
          From ! not_granted
      end;
    {no, _} ->
      From ! not_granted
  end.

return(Stick) ->
  Stick ! return.

quit(Stick) ->
  Stick ! quit.