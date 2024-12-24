% HCP simple input - 2 person, 6 things, 2 cabinet, 2 rooms.

person(1..2).            
thing(3..8).              
cabinet(9..10).           
room(15..16).   

%personToThing(P, T) means T is owned by P.
personToThing(1, 3). personToThing(1, 4). personToThing(1, 5). personToThing(1, 6). personToThing(1, 7). personToThing(2, 8).

%HCP input as per given configuration in hcp_example.asp

%legacyConfig(person(1)).
%legacyConfig(person(2)).
%legacyConfig(thing(3)).
%legacyConfig(thing(4)).
%legacyConfig(thing(5)).
%legacyConfig(thing(6)).
%legacyConfig(thing(7)).
%legacyConfig(thing(8)).
%legacyConfig(personTOthing(1,3)).
%legacyConfig(personTOthing(1,4)).
%legacyConfig(personTOthing(1,5)).
%legacyConfig(personTOthing(1,6)).
%legacyConfig(personTOthing(1,7)).
%legacyConfig(personTOthing(2,8)).
%legacyConfig(cabinet(9..10)).
%legacyConfig(room(15..16)).

% HRP simple input - new thing 21 belonging to 1, 3 long things, new cabinet, 9 and 10 become high cabinet

thing(21).
personToThing(1, 21).
thingLong(3;8;21).
% cabinet(22).
% high_cabinet(9..10).
new_cabinet(22..23).
new_room(17..20).

%HRP input as per given configuration in hrp_example.asp.

legacyConfig(person(1)).
legacyConfig(person(2)).
legacyConfig(thing(3)).
legacyConfig(thing(4)).
legacyConfig(thing(5)).
legacyConfig(thing(6)).
legacyConfig(thing(7)).
legacyConfig(thing(8)).
legacyConfig(thing(21)).
legacyConfig(personTOthing(1,3)).
legacyConfig(personTOthing(1,4)).
legacyConfig(personTOthing(1,5)).
legacyConfig(personTOthing(1,6)).
legacyConfig(personTOthing(1,7)).
legacyConfig(personTOthing(1,21)).
legacyConfig(personTOthing(2,8)).

legacyConfig(room(15)).
legacyConfig(roomTOcabinet(15,9)).

legacyConfig(room(16)).
legacyConfig(roomTOcabinet(16,10)).

legacyConfig(cabinet(9)).
legacyConfig(cabinetTOthing(9,3)).
legacyConfig(cabinetTOthing(9,4)).
legacyConfig(cabinetTOthing(9,5)).
legacyConfig(cabinetTOthing(9,6)).
legacyConfig(cabinetTOthing(9,7)).

legacyConfig(cabinet(10)).
legacyConfig(cabinetTOthing(10,8)).

thingLong(3).
thingLong(8).
thingLong(21).

cabinetDomainNew(22..23).
roomDomainNew(17..20).

% cost as per the given sample in documentation

reuseCabinetTOthingCost(0).
reuseRoomTOcabinetCost(0).
reusePersonTOroomCost(0).
reuseCabinetAsHighCost(3).
reuseCabinetAsSmallCost(0).
reuseRoomCost(0).
removeCabinetTOthingCost(2).
removeRoomTOcabinetCost(2).
removePersonTOroomCost(2).
removeCabinetCost(2).
removeRoomCost(2).
cabinetHighCost(100).
cabinetSmallCost(10).
roomCost(5). 

%Defining domains.

person(P) :- legacyConfig(person(P)).
thing(T) :- legacyConfig(thing(T)).
personTOthing(P, T) :- legacyConfig(personToThing(P, T)).
cabinet(C) :- legacyConfig(cabinet(C)).
room(R) :- legacyConfig(room(R)).
cabinetToThing(C, T) :- legacyConfig(cabinetTOthing(C, T)).
roomToCabinet(R, C) :- legacyConfig(roomTOcabinet(R, C)).
new_cabinet(C) :- cabinetDomainNew(C).
new_room(R) :- roomDomainNew(R).

%new cabinet to cabinet
cabinet(C) :- new_cabinet(C).

%new room to room
room(R) :- new_room(R).

% One thing gets only one cabinet.
1 { cabinetToThing(C, T) : cabinet(C) } 1 :- thing(T).

% One room gets one person.
% 1 { roomToPerson(R, P) : person(P) } 1 :- room(R).
% 1 { roomToPerson(R, P) : room(R) } 1 :- person(P).
1 { roomToPerson(R, P) : person(P) } 1 :- used_room(R).
1 { roomToPerson(R, P) : used_room(R) } 1 :- person(P).

% One cabinet will have only one person's things
:- cabinetToThing(C, Ti), cabinetToThing(C, Tii), personToThing(Pi, Ti), personToThing(Pii, Tii), Pi != Pii.

% Cabinet will have the person's things to whom the room belongs
:- roomToPerson(Ri, P), roomToCabinet(Rii, C), personToThing(P, T), cabinetToThing(C, T), Ri != Rii.

% A cabinet is used if it has a thing in it.
used_cabinet(C) :- cabinetToThing(C, T).

%room is used if it has a cabinet in it.
used_room(R) :- roomToCabinet(R,C).

% Used cabinet can have maximum of 5 things.
% 1{ cabinetToThing(C, T):thing(T)} 5 :- cabinet(C).
1{ cabinetToThing(C, T):thing(T)} 5 :- used_cabinet(C).

% A room can have maximum of 4 cabinets.
% 1 {roomToCabinet(R, C) : room(R)} 4 :- cabinet(C).
% :- room(R), #sum { 1 : roomToCabinet(R, C), not high_cabinet(C); 2 : roomToCabinet(R, C), high_cabinet(C) } > 4.
:- used_room(R), #sum { 1 : roomToCabinet(R, C), not high_cabinet(C); 2 : roomToCabinet(R, C), high_cabinet(C) } > 4.

% One cabinet gets only one room.
% 1 { roomToCabinet(R, C) : room(R) } 1 :- cabinet(C).
1 { roomToCabinet(R, C) : room(R) } 1 :- used_cabinet(C).

%cabinet is converted to high if it contains long things
high_cabinet(C) :- cabinetToThing(C, T), thingLong(T).

% in general cabinets are small, unless they are needed for long things
small_cabinet(C) :- cabinetToThing(C, T), not thingLong(T).

%long thing goes in high cabinet.
:- thingLong(T), cabinetToThing(C, T), not high_cabinet(C).

%costs

% cost of reusing cabinet for a thing
cost(reuseCabinetThingCost) :- used_cabinet(C), reuseCabinetTOthingCost(reuseCabinetThingCost). reuseCabinetAsSmallCost(0).

% cost of reusing room for a cabinet
cost(reuseRoomCabinetCost) :- used_room(R), reuseRoomTOcabinetCost(reuseRoomCabinetCost).

% cost of reusing room for person
cost(reuseRoomPersonCost) :- used_room(R), reusePersonTOroomCost(reuseRoomPersonCost).

% cost of reusing high cabinets for long things
cost(reuseCabinetHighCost) :- used_cabinet(C), high_cabinet(C), reuseCabinetAsHighCost(reuseCabinetHighCost).

% cost of reusing small cabinet for a thing
cost(reuseCabinetSmallCost) :- used_cabinet(C), small_cabinet(C), reuseCabinetAsSmallCost(reuseCabinetSmallCost). 

% cost of reusing room
cost(reusingRoomCost) :- used_room(R), reuseRoomCost(reusingRoomCost).

% cost of removing a thing from cabinet
cost(removeCabinetThingCost) :- not cabinetToThing(C, T), thing(T), cabinet(C), removeCabinetTOthingCost(removeCabinetThingCost).

% cost of removing a cabinet from room
cost(removeRoomCabinetCost) :- not roomToCabinet(R, C), room(R), cabinet(C), removeRoomTOcabinetCost(removeRoomCabinetCost).

% cost of removing a person from room
cost(removePersonRoomCost) :- not roomToPerson(R, P), room(R), person(P), removePersonTOroomCost(removePersonRoomCost).

% Cost of removing room
cost(removeTheRoomCost) :- room(R), not used_room(R), removeRoomCost(removeTheRoomCost).

% Cost of removing cabinet
cost(removeTheCabinetCost) :- cabinet(C), not used_cabinet(C), removeCabinetCost(removeTheCabinetCost).

% cost of using high cabinet 
cost(CabinetHighUseCost) :- high_cabinet(C), cabinetHighCost(CabinetHighUseCost).

% cost of using small cabinet 
cost(CabinetUseCost) :- small_cabinet(C), cabinetSmallCost(CabinetUseCost).

% cost of assigning a room 
cost(RoomAssigningCost) :- used_room(R), not room(R), roomCost(RoomAssigningCost).

% total cost and its minimization
%total_cost(Total) :- Total = #sum { C : cost(C) }.
#minimize {C : cost(C) }.

#show used_cabinet/1.
% #show room/1.
#show used_room/1.
#show cabinetToThing/2.
#show roomToCabinet/2.
#show roomToPerson/2.
#show high_cabinet/1.
% #show new_cabinet/1.
% #show cabinetDomainNew/1.
% #show new_room/1.
% #show roomDomainNew/1.
#show small_cabinet/1.















 