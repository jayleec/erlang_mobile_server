%%%-------------------------------------------------------------------
%%% @author Lee
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. 1월 2017 오후 3:43
%%%-------------------------------------------------------------------
-module(mon_fcm).
-author("Lee Jae Kyung").

-include("mon_record.hrl").

%% API
-export([push/2, send/2]).

push(Id, Message) ->
  case mnesia:dirty_read(users, Id) of
    [U] ->
      send(U#users.token, Message);
    _ ->
      fail
  end.

send(Token, Message) ->
  %%  Payload
  Data = [
    {<<"to">>,Token},
    {<<"notification">>, [
      {<<"title">>, Message},
      {<<"text">>, Message}
    ]}
  ],
%%  Authorization=MY GOOGLE SERVER KEY
  GoogleKey = "key=AIzaSyAEuhsvoH8ruRvbwyScfD7sb0qA9gqAO-E",
  URL = "https://fcm.googleapis.com/fcm/send",
  Header = [{"Authorization", GoogleKey}],
  ContentType = "application/json",
  Payload = jsx:encode(Data),
  io:format("INPUT CHECK : ~ts~n", [Payload]),
  httpc:request(post, {URL, Header, ContentType, Payload}, [],[]).







