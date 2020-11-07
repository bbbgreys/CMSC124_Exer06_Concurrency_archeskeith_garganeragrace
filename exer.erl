-module(exer).
-compile(export_all).
-import(string,[equal/2]). 

% romeo = pong, first chat
% juliet = ping, second chat

%used to initialize first message/chat
init_chat()->
    Name = io:get_line("Enter your name: "),
    register(chat1,spawn(exer,chat1,[Name])).

chat1(Name) -> 

    receive
        %_ is for the receiving end of the other node, to match the cases 
        {ping,Chat2_Node,_} -> 
            %This accepts the convo of chat1, and sends it to the other node
            Theconvo = io:get_line("You: "),
            Chat2_Node ! {response,Name,Theconvo},
            chat1(Name);
        %receives the input of the other node, and sends another input from this node
        {Chat2_Node,Theconvo2,Name2} ->
            io:format("~p: ~s",[Name2,Theconvo2]),
            Bye_string = "bye",
            Theconvo = io:get_line("You: "),
            Status = equal(Bye_string,Theconvo),
            if
                Status =:= false ->
                    Chat2_Node ! {response, Name,Theconvo},
                    chat1(Name);
                true-> 
                    Chat2_Node ! bye
            end;
        bye ->
            io:format("Your partner disconnected.~n")

    end.

%used to initialize the second chat 
init_chat2(Chat1_Node) ->
    Name2 = io:get_line("Enter your name: "),
    spawn(exer,chat2,[1,Chat1_Node,Name2]).

%ping part with N 
chat2(1,Chat1_Node,Name2) ->
    {chat1, Chat1_Node} ! {ping,self(),Name2},
    chat2(1+1,Name2,Chat1_Node);

chat2(N, Name2,Chat1_Node)-> 
    receive
        {response,Name,Theconvo}->
            io:format("~p: ~s",[Name,Theconvo]),
            Theconvo2 = io:get_line("You: "),
            Bye_string = "bye",
            Status = equal(Bye_string,Theconvo),
            if
                Status =:= false ->
                    {chat1,Chat1_Node} ! {self(),Theconvo2,Name2},
                    chat2(N+1,Name2,Chat1_Node);
                true ->
                    Chat1_Node ! bye
            end;
    
        bye ->
            io:format("Your partner disconnected.~n")
    end.
        




    
% REFERENCES:
% Checking if both strings are equal: https://www.tutorialspoint.com/erlang/erlang_equal.htm