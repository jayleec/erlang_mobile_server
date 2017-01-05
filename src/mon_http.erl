
%%%-------------------------------------------------------------------
%%% @author Lee
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 12월 2016 오후 5:47
%%%-------------------------------------------------------------------
-module(mon_http).
-author("Lee Jae Kyung").

%% API
-export([init/2 , handle/4 , terminate/3]).

init(Req, State) ->
%% read data
  Api = cowboy_req:binding(api, Req),
  What = cowboy_req:binding(what,Req),
  Opt = cowboy_req:binding(opt, Req),

  io:format("~napi = ~p, what=~p, opt = ~p ~n",[Api, What, Opt]),

  Reply = handle(Api, What, Opt, Req),

  Req4 = cowboy_req:reply(200,
    #{<<"content-type">> => <<"text/plain">>},
      Reply, Req),
  {ok, Req4, State}.

handle(<<"login">>, _, _, Data) ->
%% cowboy 2.0에 새로 추가된 부분
  Qs = cowboy_req:parse_qs(Data),
%%  io:format("~n Data : ~p~n",[Qs] ),
  Id = proplists:get_value(<<"id">>, Qs),
  Password = proplists:get_value(<<"password">>, Qs),
  case mon_users:login(Id, Password) of
    {ok, SessionKey} ->
      jsx:encode([
        {<<"result">>, <<"ok">>},
        {<<"session_key">>, SessionKey}]);
    fail ->
      jsx:encode([{<<"result">>, <<"fail">>}])
  end;

handle(<<"join">>, _, _, Data) ->
  Qs = cowboy_req:parse_qs(Data),
  Id = proplists:get_value(<<"id">>, Qs),
  Password = proplists:get_value(<<"password">>, Qs),
  case mon_users:join(Id, Password) of
    fail ->
      jsx:encode([{<<"result">>, <<"duplicated">>}]);
    ok ->
      jsx:encode([{<<"result">>, <<"join">>}])
  end;

handle(<<"users">>, <<"point">>, _, Data) ->
  Qs = cowboy_req:parse_qs(Data),
  SessionKey = proplists:get_value(<<"session_key">>, Qs),
  Point1 = proplists:get_value(<<"point">>, Qs),
  Point = binary_to_integer(Point1),
  case mon_users:point(SessionKey, Point) of
      ok ->
        jsx:encode([{<<"result">>, <<"ok">>}]);
      fail ->
        jsx:encode([{<<"result">>, <<"fail">>}])
  end;

handle(<<"users">>, <<"token">>, _, Data) ->
  Qs = cowboy_req:parse_qs(Data),
  SessionKey = proplists:get_value(<<"session_key">>, Qs),
  Token = proplists:get_value(<<"token">>, Qs),
  case mon_users:token(SessionKey, Token) of
    ok ->
      jsx:encode([{<<"result">>, <<"ok">>}]);
    fail ->
      jsx:encode([{<<"result">>, <<"fail">>}])
  end;

handle(<<"hello">>, <<"world">>, _, _) ->
  jsx:encode([{<<"result">>, <<"world">>}]);

handle( _, _, _, _) ->
  jsx:encode([{<<"result">>, <<"error">>}]).

terminate(_Reason, _Req, _State) ->
  ok.