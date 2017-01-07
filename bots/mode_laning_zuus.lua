------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_laning_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local LaningStates={
	Start=0,
	Moving=1,
	WaitingForCS=2,
	CSing=3,
	WaitingForCreeps=4,
	MovingToPos=5,
	GetReadyForCS=6,
	GettingBack=7,
	MovingToLane=8
}

local CurLane = LANE_BOT;
local LaningState = LaningStates.Start;
local LanePos = 0.0;
local ShouldPush=false;
local backTimer=-10000;
local IsCore=true;

local DamageThreshold=1.0;
local MoveThreshold=1.0;

function OnStart()
	mode_generic_laning.OnStart();
	if DotaTime()>2 then
		LoadUpdates();
	end
end

function OnEnd()
	mode_generic_laning.OnEnd();
end

function GetDesire()
	return mode_generic_laning.GetDesire();
end


function GetBack()
	local npcBot=GetBot();
	
	local Enemies=npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);
	
	if Enemies== nil or #Enemies==0 then
		return true;
	end
	
	if npcBot:IsSilenced() or #Enemies>3 or npcBot:GetCurrentMovementSpeed()<250 then
		backTimer=DotaTime();
		npcBot:Action_MoveToLocation(GetLocationAlongLane(CurLane,LanePos-0.02));
		return false;
	end
	
	for _,enemy in pairs(Enemies) do
		if  GetUnitToUnitDistance(npcBot,enemy)<=500  then
			backTimer=DotaTime();
			npcBot:Action_MoveToLocation(GetLocationAlongLane(CurLane,LanePos-0.02));
			return false;
		end
	end
	
	if DotaTime()-backTimer<1 then
		npcBot:Action_MoveToLocation(GetLocationAlongLane(CurLane,LanePos-0.02));
		return false;
	end
	
	return true;
end

local function Updates()
	local npcBot=GetBot();

	if DotaTime()<100 then
		CurLane=npcBot:GetAssignedLane();
	end

	local Enemies=npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);
	
	if CurLane~=nil and GetUnitToLocationDistance(npcBot,GetLocationAlongLane(CurLane,0.0)) < 1000 then
		CurLane=Utility.ConsiderChangingLane(CurLane);
	end
	
	LanePos = Utility.PositionAlongLane(CurLane);
	

	if Utility.IsItemInInventory("item_veil_of_discord")~=nil then
		ShouldPush=true;
	else
		if Enemies~=nil and #Enemies>1 then
			ShouldPush=true;
		else
			ShouldPush=false;
		end
	end
	
	local Towers=npcBot:GetNearbyTowers(1000,true);
	
	if (Enemies~=nil and #Enemies>1) or (Towers~=nil and #Towers>0) or ShouldPush then
		npcBot.CreepDist=675;
	else
		npcBot.CreepDist=550;
	end
	
	if ((not(npcBot:IsAlive())) or (LanePos<0.15 and LaningState~=LaningStates.Start)) then
		LaningState=LaningStates.Moving;
	end
end

function SaveUpdates()
	local npcBot=GetBot();
	
	npcBot.LaningState=LaningState;
	npcBot.LanePos=LanePos;
	npcBot.CurLane=CurLane;
	npcBot.MoveThreshold=MoveThreshold;
	npcBot.DamageThreshold=DamageThreshold;
	npcBot.ShouldPush=ShouldPush;
	npcBot.IsCore=IsCore;
end

function LoadUpdates()
	local npcBot=GetBot();

	LaningState=npcBot.LaningState;
	LanePos=npcBot.LanePos;
	CurLane=npcBot.CurLane;
	MoveThreshold=npcBot.MoveThreshold;
	DamageThreshold=npcBot.DamageThreshold;
	ShouldPush=npcBot.ShouldPush;
	IsCore=npcBot.IsCore;
end

function Think()
	local npcBot=GetBot();

	Updates();
	SaveUpdates();
	
	if GetBack() then
		--LaningState = mode_generic_laning.Thinker(LaningState,LanePos,CurLane,1.0,1.0,ShouldPush);
		mode_generic_laning.Think();
		LaningState=npcBot.LaningState;
		LoadUpdates();
	end
end

--------
