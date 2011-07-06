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
-module(rabbit_mgmt_wm_user).

-export([init/1, resource_exists/2, to_json/2,
         content_types_provided/2, content_types_accepted/2,
         is_authorized/2, allowed_methods/2, accept_content/2,
         delete_resource/2, put_user/1]).

-include("rabbit_mgmt.hrl").
-include_lib("webmachine/include/webmachine.hrl").
-include_lib("rabbit_common/include/rabbit.hrl").

%%--------------------------------------------------------------------
init(_Config) -> {ok, #context{}}.

content_types_provided(ReqData, Context) ->
   {[{"application/json", to_json}], ReqData, Context}.

content_types_accepted(ReqData, Context) ->
   {[{"application/json", accept_content}], ReqData, Context}.

allowed_methods(ReqData, Context) ->
    {['HEAD', 'GET', 'PUT', 'DELETE'], ReqData, Context}.

resource_exists(ReqData, Context) ->
    {case user(ReqData) of
         {ok, _}    -> true;
         {error, _} -> false
     end, ReqData, Context}.

to_json(ReqData, Context) ->
    {ok, User} = user(ReqData),
    rabbit_mgmt_util:reply(rabbit_mgmt_format:internal_user(User),
                           ReqData, Context).

accept_content(ReqData, Context) ->
    Username = rabbit_mgmt_util:id(user, ReqData),
    rabbit_mgmt_util:with_decode(
      [], ReqData, Context,
      fun(_, User) ->
              put_user([{name, Username} | User]),
              {true, ReqData, Context}
      end).

delete_resource(ReqData, Context) ->
    User = rabbit_mgmt_util:id(user, ReqData),
    rabbit_auth_backend_internal:delete_user(User),
    {true, ReqData, Context}.

is_authorized(ReqData, Context) ->
    rabbit_mgmt_util:is_authorized_admin(ReqData, Context).

%%--------------------------------------------------------------------

user(ReqData) ->
    rabbit_auth_backend_internal:lookup_user(rabbit_mgmt_util:id(user, ReqData)).

put_user(User) ->
    case {proplists:is_defined(password, User),
          proplists:is_defined(password_hash, User)} of
        {true, _} ->
            Pass = proplists:get_value(password, User),
            put_user(User, Pass, fun rabbit_auth_backend_internal:change_password/2);
        {_, true} ->
            Hash = base64:decode(proplists:get_value(password_hash, User)),
            put_user(User, Hash,
                     fun rabbit_auth_backend_internal:change_password_hash/2);
        _ ->
            put_user(User, <<>>,
                     fun rabbit_auth_backend_internal:change_password_hash/2)
    end.

put_user(User, PWArg, PWFun) ->
    Username = proplists:get_value(name, User),
    IsAdmin = proplists:get_value(administrator, User),
    case rabbit_auth_backend_internal:lookup_user(Username) of
        {error, not_found} ->
            rabbit_auth_backend_internal:add_user(
              Username, rabbit_guid:binstring_guid("tmp_"));
        _ ->
            ok
    end,
    PWFun(Username, PWArg),
    case rabbit_mgmt_util:parse_bool(IsAdmin) of
        true  -> rabbit_auth_backend_internal:set_admin(Username);
        false -> rabbit_auth_backend_internal:clear_admin(Username)
    end.
