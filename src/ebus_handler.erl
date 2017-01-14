%%%-------------------------------------------------------------------
%%% @author jay
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Jan 2017 10:12 AM
%%%-------------------------------------------------------------------
-module(ebus_handler).
-author("jay").

%% API
-export([handle_msg/2]).

handle_msg(Msg, Context) ->
%%    io:format("handle_msg started!~n"),
    Context ! {message_published, Msg}.
