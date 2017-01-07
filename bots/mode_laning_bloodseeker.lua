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
local backTimer=-1000;
local ShouldPush=false;
local IsCore=true;

local DamageThreshold=0.91;
local MoveThreshold=0.9;

function OnStart()
	mode_generic_laning.OnStart();
	if DotaTime()>2 then
		LoadUpdates();
	end
end

function OnEnd()
	mode_generic_laning.OnEnd();
end

function GetBack()
	local npcBot=GetBot();
	
	local Enemies=npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);
	
	if Enemies== nil or #Enemies==0 then
		return true;
	end
	
	for _,enemy in pairs(Enemies) do
		if npcBot:IsSilenced() or #Enemies>3 or (GetUnitToUnitDistance(npcBot,enemy)<400 and npcBot:GetHealth()<300) or (#Enemies>1 and npcBot:GetHealth()/npcBot:GetMaxHealth()<0.43) then
			backTimer=DotaTime();
			npcBot:Action_MoveToLocation(GetLocationAlongLane(CurLane,LanePos-0.02));
			return false;
		end
		
		if DotaTime()-backTimer<1.25 then
			npcBot:Action_MoveToLocation(GetLocationAlongLane(CurLane,LanePos-0.02));
			return false;
		end
	end
	
	local enemy=nil;
	
	enemy,_=Utility.GetWeakestHero(npcBot:GetAttackRange());
	if enemy==nil then
		return true;
	end
	
	if GetUnitToUnitDistance(npcBot,enemy)<=600 and (Utility.GetHeroLevel()==nil or Utility.GetHeroLevel()>4) then
		npcBot:Action_AttackUnit(enemy,true);
		return false;
	end
	
	return true;
end

local function Updates()
	local npcBot=GetBot();
	
	if DotaTime()<100 then
		CurLane=npcBot:GetAssignedLane();
	end
	
	if npcBot:GetHealth()/npcBot:GetMaxHealth()>0.75 then
		npcBot.CreepDist=450;
	else
		npcBot.CreepDist=550;
	end
	
	if CurLane~=nil and GetUnitToLocationDistance(npcBot,GetLocationAlongLane(CurLane,0.0)) < 1000 then
		CurLane=Utility.ConsiderChangingLane(CurLane);
	end
	
	if Utility.IsItemInInventory("item_power_treads")~=nil and (Utility.GetHeroLevel()==nil or Utility.GetHeroLevel()>=5) then
		ShouldPush=true;
	end
	
	LanePos = Utility.PositionAlongLane(CurLane);
	
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

function GetDesire()
	Updates();
	SaveUpdates();
	
	return mode_generic_laning.GetDesire();
end

function Think()
	local npcBot=GetBot();
	Updates();
	SaveUpdates();
	
	if npcBot:IsChanneling() or npcBot:IsUsingAbility() then
		return;
	end
	
	if GetBack() then
		mode_generic_laning.Think();
		LaningState=npcBot.LaningState;
		LoadUpdates();
	end
end

--------
