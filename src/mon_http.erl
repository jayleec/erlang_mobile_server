
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
  #{id := Id, password := Password} = cowboy_req:match_qs([id, password], Data),

  case mon_users:login(Id, Password) of
    {ok, SessionKey} ->
      jsx:encode([
        {<<"result">>, <<"ok">>},
        {<<"session_key">>, SessionKey}]);
    fail ->
      jsx:encode([{<<"result">>, <<"fail">>}])
  end;

handle(<<"join">>, _, _, Data) ->
  #{id := Id, password := Password} = cowboy_req:match_qs([id, password], Data),

  case mon_users:join(Id, Password) of
    fail ->
      jsx:encode([{<<"result">>, <<"duplicated">>}]);
    ok ->
      jsx:encode([{<<"result">>, <<"join">>}])
  end;

handle(<<"users">>, <<"point">>, _, Data) ->
  #{point := Point0, session_key := SessionKey} = cowboy_req:match_qs([point, session_key ], Data),
  Point = binary_to_integer(Point0),
  case mon_users:point(SessionKey, Point) of
      ok ->
        jsx:encode([{<<"result">>, <<"ok">>}]);
      fail ->
        jsx:encode([{<<"result">>, <<"fail">>}])
  end;

handle(<<"users">>, <<"token">>, _, Data) ->
  #{token := Token, session_key := SessionKey} = cowboy_req:match_qs([token, session_key ], Data),
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