%%   The contents of this file are subject to the Mozilla Public License
%%   Version 1.1 (the "License"); you may not use this file except in
%%   compliance with the License. You may obtain a copy of the License at
%%   http://www.mozilla.org/MPL/
%%
%%   Software distributed under the License is distributed on an "AS IS"
%%   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
%%   License for the specific language governing rights and limitations
%%   under the License.
%%
%%   The Original Code is RabbitMQ Management Plugin.
%%
%%   The Initial Developer of the Original Code is VMware, Inc.
%%   Copyright (c) 2007-2010 VMware, Inc.  All rights reserved.
-module(rabbit_mgmt_wm_help).

-export([init/1, to_html/2]).

-include("rabbit_mgmt.hrl").
-include_lib("webmachine/include/webmachine.hrl").
-include_lib("rabbit_common/include/rabbit.hrl").

%%--------------------------------------------------------------------

init(_Config) -> {ok, #context{}}.

to_html(ReqData, Context) ->
    %% TODO why does code:priv_dir(rabbit_management) not work? This does
    %% not work under "make cover":
    {ok, Help} = file:read_file(filename:join(
                                  [filename:dirname(code:which(?MODULE)),
                                   "..", "priv", "www-api", "help.html"])),
    {Help, ReqData, Context}.
