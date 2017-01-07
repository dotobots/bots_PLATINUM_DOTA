------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
_G._savedEnv = getfenv()
module( "mode_generic_ward", package.seeall )
----------
Utility = require( GetScriptDirectory().."/Utility")
----------

WardTimers={[LANE_BOT]=-1000,[LANE_TOP]=-1000,[LANE_MID]=-1000};
local WardDuration=340;

function  OnStart()
	Utility.InitPath();
	local npcBot=GetBot();
	npcBot.IsWarding=true;
end

function OnEnd()
	Utility.InitPath();
	local npcBot=GetBot();
	npcBot.IsWarding=false;
end

function GetDesire()
	local npcBot=GetBot();
	
	if npcBot.IsWarding~=nil and npcBot.IsWarding then
		return 0.15;
	end
	
	if Utility.IsItemInInventory("item_ward_observer") then
		for _,lane in pairs(Utility.Lanes) do
			if DotaTime()-WardTimers[lane]>WardDuration and (#Utility.EnemiesNearLocation(Utility.GetWardingSpot(lane),2000)<3) then
				npcBot.IsWarding=true;
				Utility.InitPath();
				return 0.15;
			end
		end
	end
	
	return 0.0;
end

function Think()
	local npcBot=GetBot();
	if npcBot.CurLane==nil then
		npcBot.CurLane=npcBot:GetAssignedLane();
	end

	local Lane=nil;
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() then
		return;
	end
	
	if Utility.IsItemInInventory("item_ward_observer") then
		if GetTeam()==TEAM_RADIANT then
			if DotaTime()-WardTimers[LANE_MID]>WardDuration and (#Utility.EnemiesNearLocation(Utility.GetWardingSpot(LANE_MID),2000)<3) then
				Lane=LANE_MID;
			elseif DotaTime()-WardTimers[LANE_BOT]>WardDuration and (#Utility.EnemiesNearLocation(Utility.GetWardingSpot(LANE_BOT),2000)<3) then
				Lane=LANE_BOT;
			elseif DotaTime()-WardTimers[LANE_TOP]>WardDuration and (#Utility.EnemiesNearLocation(Utility.GetWardingSpot(LANE_TOP),2000)<3) then
				Lane=LANE_TOP;
			end
		else
			if DotaTime()-WardTimers[LANE_MID]>WardDuration and (#Utility.EnemiesNearLocation(Utility.GetWardingSpot(LANE_MID),2000)<3) then
				Lane=LANE_MID;
			elseif DotaTime()-WardTimers[LANE_BOT]>WardDuration and (#Utility.EnemiesNearLocation(Utility.GetWardingSpot(LANE_BOT),2000)<3) then
				Lane=LANE_BOT;
			elseif DotaTime()-WardTimers[LANE_TOP]>WardDuration and (#Utility.EnemiesNearLocation(Utility.GetWardingSpot(LANE_TOP),2000)<3) then
				Lane=LANE_TOP;
			end
		end
	end
	
	if Lane==nil then
		npcBot.IsWarding=false;
		Utility.InitPath();
		return;
	else
		local dest = Utility.GetWardingSpot(Lane);
		if GetUnitToLocationDistance(npcBot,dest)<400 then
			local ward=Utility.IsItemAvailable("item_ward_observer");
			if ward~=nil then
				npcBot:Action_UseAbilityOnLocation(ward,dest);
				WardTimers[Lane]=DotaTime();
				Utility.InitPath();
				return;
			end
		end
		Utility.MoveSafelyToLocation(dest);
	end
end

--------
for k,v in pairs( mode_generic_ward ) do	_G._savedEnv[k] = v end
