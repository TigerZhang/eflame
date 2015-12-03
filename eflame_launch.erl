#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -name eflamelaunch@`hostname`
%%
%% Copyright yunba.io 2015
%%
main([Nodename, Cookie, Seconds])->
    Node = list_to_atom(Nodename),
    CookieAtom = list_to_atom(Cookie),
    SecondsInt = list_to_integer(Seconds),
    erlang:set_cookie(node(), CookieAtom),
    pong = net_adm:ping(Node),
    io:format("Start write trace... \n"),
    rpc:call(Node, eflame2, write_trace, [global_calls_plus_new_procs, "/tmp/ef.test.0", all, SecondsInt*1000]),
    io:format("Start formact trace... \n"),
    rpc:call(Node, eflame2, format_trace, ["/tmp/ef.test.0", "/tmp/ef.test.0.out"]).
