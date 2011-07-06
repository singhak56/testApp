%% Copyright (c) 2007-2011 VMware, Inc.
%% You may use this code for any purpose.

-module(rabbit_metronome).

-behaviour(application).

-export([start/2, stop/1]).

start(normal, []) ->
    rabbit_metronome_sup:start_link().

stop(_State) ->
    ok.
