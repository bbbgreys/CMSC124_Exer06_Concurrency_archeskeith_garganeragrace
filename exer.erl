-module(exer).
-compile(export_all).
-import(string,[equal/2]). 

%TASKS FOR THE EXER:
%----------DONE--------- - Connecting Two Nodes
%----------DONE--- - Disconnecting when bye message is sent
%----------DONE--------- - Send Messages but waits for the reply of the other code
%-----NOT-STARTED-YET--- - Send Messages but does not wait for the reply of the other code

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
            Bye_string = "bye\n",
            Status1 = string:equal(Theconvo2,Bye_string),
            Status1,
            if
                Status1 == false ->
                    Theconvo = io:get_line("You: "),
                    Chat2_Node ! {response, Name,Theconvo},
                    chat1(Name);
                true-> 
                    io:format("Your partner disconnected~n")
            end
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
        %receives the response from the first node
        {response,Name,Theconvo}->
            %message that was received from the first node
            io:format("~p: ~s",[Name,Theconvo]),
            %checks if the message received is "bye" to exit the infinite recursion
            Bye_string = "bye\n",
            Status2 = string:equal(Theconvo,Bye_string),
            Status2,
            if
                Status2 == false ->
                    Theconvo2 = io:get_line("You: "),
                    {chat1,Chat1_Node} ! {self(),Theconvo2,Name2},
                    chat2(N+1,Name2,Chat1_Node);
                true ->
                    io:format("Your partner disconnected.~n")
            end
       
    end.
        




    
% REFERENCES:
% Checking if both strings are equal: https://www.tutorialspoint.com/erlang/erlang_equal.htm


