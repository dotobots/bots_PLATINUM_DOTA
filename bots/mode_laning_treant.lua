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
local backTimer = -1000;
local ShouldPush=false;
local IsCore=false;

local DamageThreshold=1.0;
local MoveThreshold=0.7;

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

local function Harass()
	local npcBot = GetBot();
	
	local Towers=npcBot:GetNearbyTowers(1000,true);
	
	if npcBot:GetHealth()/npcBot:GetMaxHealth()<0.65 or (Towers~=nil and #Towers>0) then
		return true;
	end
	
	local AlliedHeroes = npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
	
	local NoCoreAround=true;
	local MyCore=nil
	for _,hero in pairs(AlliedHeroes) do
		if Utility.IsCore(hero) then
			NoCoreAround=false;
			MyCore=hero;
		end
	end
	
	local Enemies = npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);
	
	if Enemies==nil or #Enemies==0 then
		return true;
	end
	
	if MyCore==nil or (Enemies~=nil and #Enemies>2) then
		for _,enemy in pairs(Enemies) do
			if npcBot:IsSilenced() or GetUnitToUnitDistance(npcBot,enemy)<=600 or #Enemies>2 then
				backTimer=DotaTime();
				npcBot:Action_MoveToLocation(GetLocationAlongLane(CurLane,LanePos-0.02));
				return false;
			end
			if DotaTime()-backTimer<1 then
				npcBot:Action_MoveToLocation(GetLocationAlongLane(CurLane,LanePos-0.02));
				return false;
			end
		end
		return true;
	end
	
	local enemy=nil;
	local mindis=100000;
	for _,en in pairs(Enemies) do
		if en~=nil and GetUnitToUnitDistance(en,MyCore)<mindis then
			mindis=GetUnitToUnitDistance(en,MyCore);
			enemy=en;
		end
	end
	
	if mindis>800 then
		return true;
	end
	
	local ability=npcBot:GetAbilityByName("treant_leech_seed");
	if ability:IsFullyCastable() and npcBot:GetMana()>=2*ability:GetManaCost() and (GetUnitToUnitDistance(MyCore,enemy)<450 or (npcBot:GetHealth()/npcBot:GetMaxHealth()<0.75 and GetUnitToUnitDistance(npcBot,enemy)<=ability:GetCastRange())) then
		npcBot:Action_UseAbilityOnEntity(ability,enemy);
		return false;
	else
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
	
	local Enemies=npcBot:GetNearbyHeroes(1500,true,BOT_MODE_NONE);
	
	
	local AlliedHeroes = npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
	
	local NoCoreAround=true;
	local MyCore=nil
	for _,hero in pairs(AlliedHeroes) do
		if Utility.IsCore(hero) then
			NoCoreAround=false;
			MyCore=hero;
		end
	end
	
	if Enemies==nil or #Enemies<2 or (not NoCoreAround) then
		npcBot.CreepDist=550;
	else
		npcBot.CreepDist=950;
	end
	
	if CurLane~=nil and GetUnitToLocationDistance(npcBot,GetLocationAlongLane(CurLane,0.0)) < 1000 then
		CurLane=Utility.ConsiderChangingLane(CurLane);
	end

	LanePos = Utility.PositionAlongLane(CurLane);

	
	if ((not(npcBot:IsAlive())) or (LanePos<0.15 and LaningState~=LaningStates.Start)) then
		LaningState=LaningStates.Moving;
	end
end

local function GetBack()
	local npcBot=GetBot();
	local lvl=Utility.GetHeroLevel();
	
	local Towers=npcBot:GetNearbyTowers(1000,true);
		
	if lvl<7 and Towers~=nil and #Towers>0 then
		local dest=GetLocationAlongLane(npcBot.CurLane,npcBot.LanePos-0.04)+RandomVector(150);
		npcBot:Action_MoveToLocation(dest);
		return false;
	end
	
	local Enemies=npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);
	local Allies=npcBot:GetNearbyHeroes(900,false,BOT_MODE_NONE);
	
	if (Enemies~=nil and #Enemies>1) and (Allies==nil or #Allies==0) then
		local dest=GetLocationAlongLane(npcBot.CurLane,npcBot.LanePos-0.04)+RandomVector(200);
		npcBot:Action_MoveToLocation(dest);
		return false;
	end
	
	return true;
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
	
	if GetBack() and Harass() then
		--LaningState = mode_generic_laning.Thinker(LaningState,LanePos,CurLane,0.80,1.0,ShouldPush);
		mode_generic_laning.Think();
		LaningState=npcBot.LaningState;
		LoadUpdates();
	end
end

--------
