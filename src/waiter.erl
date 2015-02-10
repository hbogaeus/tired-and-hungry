-module(waiter).
-author("Henry Bogaeus").

-compile([debug_info, export_all]).


start(Philos) -> spawn_link(fun() -> party(Philos, 0, 2) end).

party(Philos, EaterOne, EaterTwo) ->
  io:format("Party started with ~w and ~w ~n", [EaterOne, EaterTwo]),
  Eater1 = element((EaterOne rem 5) + 1, Philos),
  Eater2 = element((EaterTwo rem 5) + 1, Philos),
  Eater1 ! {wake, self()},
  Eater2 ! {wake, self()},
  io:format("Invitations sent to ~w and ~w!~n", [Eater1, Eater2]),

  receive
    done ->
      receive
        done ->
          party(Philos, EaterOne + 1, EaterTwo + 1)
      end
  end.