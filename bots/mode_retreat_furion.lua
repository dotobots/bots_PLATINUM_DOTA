------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_retreat_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local Abilities={
"furion_sprout",
"furion_teleportation",
"furion_force_of_nature",
"furion_wrath_of_nature"
};

local IsInLane=true;
local IsRetreating=false;
local IsUsingCombo=false;
local CurLane=LANE_BOT;
local LanePos=0.0;

function OnStart()
	IsUsingCombo=false;
	mode_generic_retreat.OnStart();
end

function OnEnd()
	mode_generic_retreat.OnEnd();
end

function GetDesire()
	return mode_generic_retreat.GetDesire();
end

local function CanUseRetreatCombo()
	if IsUsingCombo then
		return true;
	end
	
	local npcBot=GetBot();
	
	local creeps=npcBot:GetNearbyCreeps(275,true);
	local allyCreeps=npcBot:GetNearbyCreeps(275,false);
	local heroes=npcBot:GetNearbyHeroes(275,true,BOT_MODE_NONE);
	local towers=npcBot:GetNearbyTowers(400,true);
	
	if (creeps~=nil and #creeps>0) or (allyCreeps~=nil and #allyCreeps>0) or (heroes~=nil and #heroes>0) or (Think~=nil and #towers>0) then
		return false;
	end

	local aq=npcBot:GetAbilityByName(Abilities[1]);
	local aw=npcBot:GetAbilityByName(Abilities[2]);
	
	if aq==nil or aw==nil then
		return false;
	end
	
	if aq:IsFullyCastable() and aw:IsFullyCastable() and aq:GetManaCost()+aw:GetManaCost()<=npcBot:GetMana() then
		print('decided to use retreat combo.');
		return true;
	end
	
	return false;
end

local function RetreatCombo()
	local npcBot=GetBot();
	
	local aq=npcBot:GetAbilityByName(Abilities[1]);
	local aw=npcBot:GetAbilityByName(Abilities[2]);	
	
	if IsUsingCombo and aw:IsFullyCastable() and (not aq:IsFullyCastable()) then
		local dest=GetLocationAlongLane(CurLane,0.0);
		npcBot:Action_UseAbilityOnLocation(aw,dest);
		IsUsingCombo=false;
		return;
	end
	
	if aq:IsFullyCastable() then
		npcBot:Action_UseAbilityOnEntity(aq,npcBot);
		IsUsingCombo=true;
	end
end

function Think()
	local npcBot=GetBot();
	if npcBot:IsUsingAbility() then
		return;
	end
	
	if CanUseRetreatCombo() and GetUnitToLocationDistance(npcBot,GetLocationAlongLane(CurLane,0.0))>2000 and (not (Utility.IsItemInInventory("item_invis_sword") or Utility.IsItemInInventory("item_silver_edge"))) then
		RetreatCombo();
		return;
	end
	
	local Enemies=npcBot:GetNearbyHeroes(1400,true,BOT_MODE_NONE);
	local Towers=npcBot:GetNearbyTowers(900,true);
	if (Enemies==nil or #Enemies==0) and (Towers==nil or #Towers==0) and GetUnitToLocationDistance(npcBot,GetLocationAlongLane(CurLane,0.0))>2000 then
		local ability=npcBot:GetAbilityByName(Abilities[2]);
		if ability:IsFullyCastable() and ability:GetLevel()>2 then
			npcBot:Action_UseAbilityOnLocation(ability,GetLocationAlongLane(CurLane,0.0));
			return;
		end
	end

	mode_generic_retreat.Think();
end

--------
