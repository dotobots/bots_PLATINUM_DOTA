------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_attack_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local Abilities={
"furion_sprout",
"furion_teleportation",
"furion_force_of_nature",
"furion_wrath_of_nature"
};

local UltDamage={
110,140,170
};

function OnStart()
	mode_generic_attack.OnStart();
end

function OnEnd()
	mode_generic_attack.OnEnd();
end

function GetDesire()
	return mode_generic_attack.GetDesire();
end

local function UseQ()
	local npcBot=GetBot();
	
	local ability=npcBot:GetAbilityByName(Abilities[1]);
	if ability==nil or (not ability:IsFullyCastable()) then
		return false;
	end
	
	if GetUnitToUnitDistance(npcBot.Target,npcBot) < ability:GetCastRange()-75 then
		npcBot:Action_UseAbilityOnEntity(ability,npcBot.Target);
		return true;
	end
	return false;
end

local function UseUlt()
	local npcBot = GetBot();
	
	local ability=npcBot:GetAbilityByName(Abilities[4]);
	if ability==nil or (not ability:IsFullyCastable()) then
		return false;
	end
	
	local i = RandomInt(1,5);
	local enemy=GetTeamMember(Utility.GetOtherTeam(),i);
	if Utility.NotNilOrDead(enemy) and enemy:CanBeSeen() then
		npcBot:Action_UseAbilityOnEntity(ability,enemy);
		return true;
	else
		npcBot:Action_UseAbilityOnEntity(ability,npcBot.Target);
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
	
	if (not npcBot.IsAttacking) or npcBot.Target==nil then
		return;
	end
	
	if (not UseQ()) and (not UseUlt()) then
		npcBot:Action_AttackUnit(npcBot.Target,true);
	end
end

--------
