%%%-------------------------------------------------------------------
%%% @author jay
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Jan 2017 1:15 PM
%%%-------------------------------------------------------------------
-module(mon_apns).
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
  {Address, Cert, Key} =
    {"gateway.push.apple.com",
      "./key/CertificateSigningRequest.certSigningRequest",
      "./key/APNsAuthKey_BF5YMX4RL3.p8"},
  Port = 2195,
  Options = [{certfile, Cert}, {keyfile, Key}, {mode, binary},
    {password, ""},
    {verify, verify_none}],
  Timeout = 10000,
  case ssl:connect(Address, Port, Options, Timeout) of
    {ok, Socket} ->
      PayloadBin = create_payload(Message),
      PayloadLength = size(PayloadBin),

      Frame = <<1:8, 32:16/big, Token:256/big,
        2:8, PayloadLength:16/big, PayloadBin/binary>>,
      FrameLength = size(Frame),
      Packet = <<2:8, FrameLength:32/big, Frame/binary>>,
      SendRet = ssl:send(Socket, Packet),
      io:format("push_apns send ~p result(~p)~n",[PayloadBin, SendRet]),
      Recv = ssl:recv(Socket, 0, 1000),
      io:format("push_apns recv ~p~n",[Recv]),
      ssl:close(Socket);
    {error, Reason} ->
      {error, Reason}
  end.

create_payload(Message) ->
  Data =
    [{<<"aps">>, [
      {<<"alert">>, Message},
      {<<"badge">>, 0}]
    }],
  jsx:encode(Data).