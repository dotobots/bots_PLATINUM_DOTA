------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
_G._savedEnv = getfenv()
module( "mode_generic_assemble", package.seeall )
----------
Utility = require( GetScriptDirectory().."/Utility")
----------

function  OnStart()
end

function OnEnd()
	local npcBot=GetBot();
	npcBot.IsAssmbling=false;
end

function GetDesire()
	local npcBot=GetBot();
	
	if npcBot.IsAssmbling==nil then
		npcBot.IsAssmbling=false;
		return 0.0;
	end
	
	if npcBot.IsAssmbling then
		return 0.38;
	end
	
	if npcBot.CurLane==nil or npcBot.LanePos==nil or GetUnitToLocationDistance(npcBot,GetLocationAlongLane(npcBot.CurLane,npcBot.LanePos))>=500 then
		return 0.0;
	end
	
	if (npcBot:GetActiveMode()~=BOT_MODE_LANING and npcBot:GetActiveMode()~=BOT_MODE_ASSEMBLE) or npcBot.LanePos>0.8 then
		return 0.0;
	end
	
	local MinLanePos=npcBot.LanePos;
	local MaxLanePos=npcBot.LanePos;
	
	local nAl=0;
	for i=1,5,1 do
		local Ally=GetTeamMember(GetTeam(),i);
		if Ally~=nil and Ally.LanePos~=nil and Utility.NotNilOrDead(Ally) and Ally.CurLane==npcBot.CurLane and Utility.IsCore(Ally) and (Ally:GetActiveMode()==BOT_MODE_LANING or Ally:GetActiveMode()==BOT_MODE_ASSEMBLE) and (GetUnitToLocationDistance(Ally,GetLocationAlongLane(Ally.CurLane,Ally.LanePos))<500) then
			MinLanePos=Min(MinLanePos,Ally.LanePos);
			MaxLanePos=Max(MaxLanePos,Ally.LanePos);
			nAl=nAl+1;
		end
	end
	
	if nAl<2 then
		return 0.0;
	end

	if MaxLanePos-MinLanePos>0.1 and MaxLanePos-MinLanePos<0.6 then
		return 0.38;
	end
	
	return 0.0;
end

function Think()
	local npcBot=GetBot();

	local AvPos=0;
	local nAl=0;
	
	local MinLanePos=npcBot.LanePos;
	local MaxLanePos=npcBot.LanePos;
	
	for i=1,5,1 do
		local Ally=GetTeamMember(GetTeam(),i);
		if Ally~=nil and Ally.LanePos~=nil and Utility.NotNilOrDead(Ally) and Ally.CurLane==npcBot.CurLane and Utility.IsCore(Ally) and (Ally:GetActiveMode()==BOT_MODE_LANING or Ally:GetActiveMode()==BOT_MODE_ASSEMBLE)  and (GetUnitToLocationDistance(Ally,GetLocationAlongLane(Ally.CurLane,Ally.LanePos))<500) then
			nAl=nAl+1;
			AvPos=AvPos+Ally.LanePos;
			MinLanePos=Min(MinLanePos,Ally.LanePos);
			MaxLanePos=Max(MaxLanePos,Ally.LanePos);
		end
	end
	
	if nAl <= 1 or MaxLanePos-MinLanePos < 0.05 then
		npcBot.IsAssmbling=false;
		return;
	end
	
	print(npcBot:GetUnitName(),AvPos,npcBot.LanePos);
	
	AvPos=Min(AvPos/nAl,0.75);
	
	local loc=GetLocationAlongLane(npcBot.CurLane,AvPos) + RandomVector(300);
	npcBot:Action_MoveToLocation(loc);
	npcBot.LanePos=Utility.PositionAlongLane(npcBot.CurLane);
end

--------
for k,v in pairs( mode_generic_assemble ) do	_G._savedEnv[k] = v end
