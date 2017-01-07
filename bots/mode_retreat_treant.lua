------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_retreat_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local Abilities =
{
"treant_natures_guise",
"treant_leech_seed",
"treant_living_armor",
"treant_overgrowth"
}

local IsInLane=true;
local IsRetreating=false;
local CurLane=LANE_BOT;
local LanePos=0.0;

function OnStart()
	mode_generic_retreat.OnStart();
end

function OnEnd()
	mode_generic_retreat.OnEnd();
end

function GetDesire()
	return mode_generic_retreat.GetDesire();
end

local function ConsiderUlt()
	local npcBot = GetBot();
	local ability = npcBot:GetAbilityByName(Abilities[4]);
	
	if not ability:IsFullyCastable() then
		return;
	end

	local enemy=nil;
	local health=100000;
	enemy,health = Utility.GetWeakestHero(800);
	if enemy==nil then
		return;
	end
	npcBot:Action_UseAbility(ability);
end

function Think()
	local npcBot=GetBot();
	
	ConsiderUlt();
	
	mode_generic_retreat.Think();
end

--------
