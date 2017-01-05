%%%-------------------------------------------------------------------
%%% @author Lee
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 1월 2017 오전 9:38
%%%-------------------------------------------------------------------
-author("Lee Jae Kyung").

-record(users, {
  id,
  password,
  token,
  level=0,
  exp=0,
  point=0}).