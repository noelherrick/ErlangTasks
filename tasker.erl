-module(tasker).
-import(uuid).
-include("tasker.hrl").
-export([init/0]).
-export([insert_user/2]).
-export([read/1]).
-export([insert_task/3]).
-export([get_tasks/1]).

init() ->
	mnesia:create_table(users,[{attributes,record_info(fields,users)}]),
	mnesia:create_table(tasks,[{attributes,record_info(fields,tasks)}]).

insert_user(Username, Password) ->
	T = fun() ->
		X = #users{username=Username,
		password=Password
		},
		mnesia:write(X)
	end,
	mnesia:transaction(T).

insert_task(Username, Subject, Description) ->
	T = fun() ->
		X = #tasks{
		id=uuid:v4(),
		username=Username,
		subject=Subject,
		description=Description
		},
		mnesia:write(X)
	end,
	mnesia:transaction(T).
	
read(Username) ->
	R = fun() ->
		mnesia:read(users,Username,write)
	end,
	mnesia:transaction(R).

get_tasks(Username) ->
	get_tasks_body(get_tasks_ids(Username)).

get_tasks_body ([First | Rest]) ->
	R = fun() ->
		mnesia:read(tasks,First,write)
	end,
	{_, [Body | _]} = mnesia:transaction(R),
	[Body | get_tasks_body(Rest)];

get_tasks_body ([]) ->
	[].

get_tasks_ids(Username) ->
	R = fun() ->
		MatchHead = #tasks{id='$1', username='$2', _='_', _='_'},
		Guard = {'==', '$2', Username},
		Result = '$1',
		mnesia:select(tasks,[{MatchHead, [Guard], [Result]}])
	end,
	{_, List} = mnesia:transaction(R),
	List.