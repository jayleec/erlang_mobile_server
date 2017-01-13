%%%-------------------------------------------------------------------
%%% @author Lee
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 12월 2016 오전 10:50
%%%-------------------------------------------------------------------
-module(mon_app).
-author("Lee Jae Kyung").

-behaviour(application).

%% Application callbacks
-export([start/2,
  stop/1]).

%%%===================================================================
%%% Application callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called whenever an application is started using
%% application:start/[1,2], and should start the processes of the
%% application. If the application is structured according to the OTP
%% design principles as a supervision tree, this means starting the
%% top supervisor of the tree.
%%
%% @end
%%--------------------------------------------------------------------
-spec(start(StartType :: normal | {takeover, node()} | {failover, node()},
    StartArgs :: term()) ->
  {ok, pid()} |
  {ok, pid(), State :: term()} |
  {error, Reason :: term()}).
start(_StartType, _StartArgs) ->
  %% necessary application
  ok = application:start(crypto),
  ok = application:start(asn1),
  ok = application:start(public_key),
  ok = application:start(cowlib),
  ok = application:start(ranch),
  ok = application:start(ssl),
  ok = application:start(cowboy),
  ok = application:start(mnesia),
  ok = application:start(inets),
  ok = application:start(ebus),
  ok = application:start(jiffy),
%%  ssl:start(),


  %% Cowboy Router
  Dispatch = cowboy_router:compile([
    {'_',[
        {"/websocket", ws_handler, []},
      {"/:api/[:what/[:opt]]", mon_http, #{}}

    ]}
  ]),

  %% HTTP server
  {ok, _} = cowboy:start_clear(my_custom_listener, 100,
    [{port, 6060}],
    #{env => #{dispatch => Dispatch}}
  ),

%%  Code reloader
  mon_reloader:start(),

%%  create ETS for Session
  ets:new(session_list, [public, named_table]),

  case mon_sup:start_link() of
    {ok, Pid} ->
      io:format("mon_sup started~n"),
      {ok, Pid};
    Error ->
      Error
  end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called whenever an application has stopped. It
%% is intended to be the opposite of Module:start/2 and should do
%% any necessary cleaning up. The return value is ignored.
%%
%% @end
%%--------------------------------------------------------------------
-spec(stop(State :: term()) -> term()).
stop(_State) ->
  ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================
