#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -sname eflamelaunch
%%
%% Copyright yunba.io 2015
%%
main([Nodename, Cookie, Seconds])->
    Node = list_to_atom(Nodename),
    CookieAtom = list_to_atom(Cookie),
    SecondsInt = list_to_integer(Seconds),
    erlang:set_cookie(node(), CookieAtom),
    pong = net_adm:ping(Node),
    rpc:call(Node, application, start, [eflame]),
    io:format("Start write trace... \n"),
    rpc:call(Node, eflame2, write_trace, [global_calls_plus_new_procs, "/tmp/ef.test.0", all, SecondsInt*1000]),
    io:format("Start formact trace... \n"),
    rpc:call(Node, eflame2, format_trace, ["/tmp/ef.test.0", "/tmp/ef.test.0.out"]),
    wait_for_file("/tmp/ef.test.0.out", 200).

wait_for_file(Filename, 0) ->
    io:format("~s not exists ~n", [Filename]);
wait_for_file(Filename, Timeout) ->
    case file:read_file_info(Filename) of
        {ok, _}         -> ok;
        {error, enoent} ->
            timer:sleep(1000),
            wait_for_file(Filename, Timeout-1);
        {error, Reason} -> io:format("~s is ~s~n", [Filename, Reason])
    end.
