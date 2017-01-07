------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_attack_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local Abilities =
{
"treant_natures_guise",
"treant_leech_seed",
"treant_living_armor",
"treant_overgrowth"
}


function OnStart()
	mode_generic_attack.OnStart();
end

function OnEnd()
	mode_generic_attack.OnEnd();
end

function GetDesire()
	local npcBot=GetBot();
	local Allies=npcBot:GetNearbyHeroes(900,false,BOT_MODE_NONE);
	local Enemies=npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);
	if (Allies==nil or #Allies==0) and (Enemies~=nil and #Enemies>1) then
		npcBot.IsAttacking=false;
		return 0.0;
	end

	return mode_generic_attack.GetDesire();
end

local function UseW()
	local npcBot = GetBot();
	local ability = npcBot:GetAbilityByName(Abilities[2]);
	
	if ability==nil or (not ability:IsFullyCastable()) then
		return false;
	end

	if GetUnitToUnitDistance(npcBot.Target, npcBot)<ability:GetCastRange() then
		npcBot:Action_UseAbilityOnEntity(ability,npcBot.Target);
		return true;
	end
	
	return false;
end

local function UseUlt()
	local npcBot = GetBot();
	local ability = npcBot:GetAbilityByName(Abilities[4]);
	
	if ability==nil or (not ability:IsFullyCastable()) then
		return false;
	end
	
	if GetUnitToUnitDistance(npcBot.Target,npcBot)<700 then
		npcBot:Action_UseAbility(ability);
		return true;
	end
	
	return false;
end

function Think()
	mode_generic_attack.Think();
	
	local npcBot=GetBot();
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() then
		return;
	end
	
	if not npcBot.IsAttacking or npcBot.Target==nil then
		return;
	end
	
	if (not UseW()) and (not UseUlt()) then
		npcBot:Action_AttackUnit(npcBot.Target,true);
	end
end

--------
--------
