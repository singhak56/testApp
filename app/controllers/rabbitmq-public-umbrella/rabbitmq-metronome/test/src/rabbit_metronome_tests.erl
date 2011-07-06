%% Copyright (c) 2007-2011 VMware, Inc.
%% You may use this code for any purpose.

-module(rabbit_metronome_tests).

-include_lib("eunit/include/eunit.hrl").
-include_lib("amqp_client/include/amqp_client.hrl").

receive_tick_test() ->
    {ok, Connection} = amqp_connection:start(#amqp_params_direct{}),
    {ok, Channel} = amqp_connection:open_channel(Connection),
    #'queue.declare_ok'{queue = Q}
        = amqp_channel:call(Channel, #'queue.declare'{exclusive = true,
                                                      auto_delete = true}),
    #'queue.bind_ok'{}
        = amqp_channel:call(Channel, #'queue.bind'{queue = Q,
                                                   exchange = <<"metronome">>,
                                                   routing_key = <<"#">>}),
    timer:sleep(2000),
    case amqp_channel:call(Channel, #'basic.get'{queue = Q, no_ack = true}) of
        {'basic.get_empty', _} -> exit(metronome_didnt_send_message);
        {_, #amqp_msg{}}       -> ok
    end,
    ok.
