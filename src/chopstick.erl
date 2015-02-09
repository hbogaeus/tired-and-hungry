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

granted(Left, Right, From, Timeout) ->
  Left_Request = spawn_link(fun() -> chopstick:request(Left, self(), Timeout) end),
  Right_Request = spawn_link(fun() -> chopstick:request(Right, self(), Timeout) end),

  receive
    {ok, _} ->
      receive
        {ok, _} ->
          From ! granted;
        {no, Left_Request} ->
          na;
        {no, Right_Request} ->
          na
      end;
    {no, _} ->
      na
  end.


.

return(Stick) ->
  Stick ! return.

quit(Stick) ->
  Stick ! quit.