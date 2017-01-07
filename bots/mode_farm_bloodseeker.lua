------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_farm_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------


local CurLane = Utility.Lanes[1];
local EyeRange=1000;

local ShouldPush=false;
local IsCore=true;

local JunglePos = 0;

local JunglingStates={
	Start=0,
	CSing=3,
	WaitingForCreeps=4,
	MovingToPos=5,
	GettingBack=7
}

local EMCamps=nil;
local HCamps=nil;

local EMCampStatus={false,false,false};
local HCampStatus={false,false};
local BRuneSpot=nil;

local CurCamp=1;
local IsHard=false;

local JunglingState=JunglingStates.Start;


-------------------------------
local function GetCenterOfCreeps(creeps)
	local center=Vector(0,0);
	local n=0.0;
	local meleeW=6;
	
	for _,creep in pairs(creeps) do
		if (string.find(creep:GetUnitName(),"melee")~=nil) then
			center=center+(creep:GetLocation()*meleeW);
			n=n+meleeW;
		else
			n=n+1;
			center=center+creep:GetLocation();
		end
	end
	
	return (center/n);
end


local function GetWeakestCreep(creeps)
	npcBot=GetBot();
	
	local weakest=nil;
	local lh=10000;
	
	for _,creep in pairs(creeps) do
		if creep:GetHealth()<lh then
			lh=creep:GetHealth();
			weakest=creep;
		end
	end
	
	return weakest;
end
-------------------------------

local function Start()
	local npcBot=GetBot();
	if GetTeam()==TEAM_RADIANT then
		BRuneSpot=Utility.Locations["RadiantBotRune"];
	else
		BRuneSpot=Utility.Locations["DireTopRune"];
	end
	npcBot:Action_MoveToLocation(BRuneSpot);
	
	npcBot.CurLane=npcBot:GetAssignedLane();
	
	if math.floor(DotaTime())>30 then
		JunglingState=JunglingStates.MovingToPos;
		return;
	end
	
	if GetTeam()==TEAM_RADIANT then
		EMCamps=Utility.Locations["RadiantEasyAndMedium"];
		HCamps=Utility.Locations["RadiantHard"];
	else
		EMCamps=Utility.Locations["DireEasyAndMedium"];
		HCamps=Utility.Locations["DireHard"];
	end
end

local function MovingToPos()
	local npcBot=GetBot();

	for i,b in pairs(EMCampStatus) do
		if b and GetUnitToLocationDistance(npcBot,EMCamps[i])<150 then
			JunglingState=JunglingStates.CSing;
			CurCamp=i;
			IsHard=false;
			return;
		end
		
		if b then
			npcBot:Action_MoveToLocation(EMCamps[i]);
			return;
		end
	end
	
	if (not ShouldPush) then
		JunglingState=JunglingStates.WaitingForCreeps;
		return;
	end
	
	for i,b in pairs(HCampStatus) do
		if b and GetUnitToLocationDistance(npcBot,HCamps[i])<150 then
			CurCamp=i;
			IsHard=true;
			JunglingState=JunglingStates.CSing;
			return;
		end
		
		if b then
			npcBot:Action_MoveToLocation(HCamps[i]);
			return;
		end
	end
	JunglingState=JunglingStates.WaitingForCreeps;
end

local function WaitingForCreeps()
	local npcBot=GetBot();
	
	for i,b in pairs(EMCampStatus) do
		if b then
			JunglingState=JunglingStates.MovingToPos;
			return;
		end
	end
	
	npcBot:Action_MoveToLocation(BRuneSpot);
	
	if not ShouldPush then
		return;
	end
	
	for i,b in pairs(HCampStatus) do
		if q then
			JunglingState=JunglingStates.MovingToPos;
			return;
		end
	end
end

local function GettingBack()

end

local function CSing()
	local npcBot=GetBot();
	
	local creeps=npcBot:GetNearbyCreeps(1000,true);
	
	if creeps==nil or #creeps==0 then
		if IsHard then
			HCampStatus[CurCamp]=false;
		else
			EMCampStatus[CurCamp]=false;
		end
		JunglingState=JunglingStates.MovingToPos;
		return;
	end
	
	local WeakestCreep=GetWeakestCreep(creeps);
	npcBot:Action_AttackUnit(WeakestCreep,true);
end

--------------------------------

local States = {
[JunglingStates.Start]=Start,
[JunglingStates.CSing]=CSing,
[JunglingStates.MovingToPos]=MovingToPos,
[JunglingStates.WaitingForCreeps]=WaitingForCreeps,
[JunglingStates.GettingBack]=GettingBack
}

----------------------------------

local function Updates()
	local npcBot=GetBot();
	
	local minutes = math.floor(DotaTime() / 60);
	local seconds = math.floor(DotaTime());
	local sec=seconds % 60;
	
	if seconds==30 or (minutes % 2 ==1 and sec==0) then
		EMCampStatus={true,true,true};
		HCampStatus={true,true};
	end
	
	if Utility.IsItemInInventory("item_power_treads") then
		ShouldPush=true;
	end
end

function  OnStart()
	print(GetBot():GetUnitName(),"Jungling!");
	if JunglingState~=JunglingStates.Start then
		JunglingState=JunglingStates.MovingToPos;
	end
end

function OnEnd()
end

function GetDesire()
	local npcBot=GetBot();

	Updates();
	
	if	npcBot.IsJungling==nil then
		npcBot.IsJungling=true;
	end
	
	if not npcBot.IsJungling then
		return 0.0;
	end
	
	if not Utility.IsItemInInventory("item_sange_and_yasha") then
		npcBot.IsJungling=true;
		return 0.16;
	end
	
	-- come out of jungle when all outer towers (or a melee racks) are gone and you have s&y
	local q=true;
	
	for _,lane in pairs(Utility.Lanes) do
		for i=1,2,1 do
			local tower=Utility.GetLaneTower(Utility.GetOtherTeam(),lane,i);
			if Utility.NotNilOrDead(tower) then
				q=false;
			end
		end
	end
	
	for _,lane in pairs(Utility.Lanes) do
		local mrax=Utility.GetLaneRacks(lane,true);
		if not Utility.NotNilOrDead(mrax) then
			q=true;
		end
	end
	
	if q then
		npcBot.CurLane=LANE_MID;
		npcBot.IsJungling=false;
		return 0.0;
	end
	
	npcBot.IsJungling=true;
	return 0.16;
end


function Think()
	local npcBot=GetBot();

	Updates();
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() then
		return;
	end
	
	States[JunglingState]();
	
	npcBot.JunglingState=JunglingState;
	npcBot.ShouldPush=ShouldPush;
end
