%%%-------------------------------------------------------------------
%%% @author Lee
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 1월 2017 오전 10:03
%%%-------------------------------------------------------------------
-module(mon_db).
-author("Lee Jae Kyung").

-include("mon_record.hrl").
%% API
-export([install/0, uninstall/0]).

install() ->
  ok = mnesia:create_schema([node()]),
  application:start(mnesia),
  mnesia:create_table(users, [{attributes, record_info(fields, users)},
    {disc_copies, [node()]}]),
  application:stop(mnesia).

uninstall() ->
  application:stop(mnesia),
  mnesia:delete_schema([node()]).