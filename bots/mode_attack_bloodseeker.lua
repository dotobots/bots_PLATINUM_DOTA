------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_attack_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------


local Abilities ={
"bloodseeker_bloodrage",
"bloodseeker_blood_bath",
"bloodseeker_thirst",
"bloodseeker_rupture"
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

local function UseW()
	local npcBot=GetBot();

	local ability=npcBot:GetAbilityByName(Abilities[2]);
	if ability==nil or (not ability:IsFullyCastable()) then
		return false;
	end
	
	local Enemies=npcBot:GetNearbyHeroes(1500,true,BOT_MODE_NONE);
	
	if (Enemies==nil or #Enemies<=1) and (ult~=nil and ult:IsFullyCastable())then
		return false;
	end
	
	if GetUnitToUnitDistance(npcBot,npcBot.Target) >1500 then
		return false;
	end
	
	local center=Utility.GetCenter(Enemies);
	if center~=nil then
		npcBot:Action_UseAbilityOnLocation(ability,center);
	end
	
	return true;
end

local function UseUlt()
	local npcBot=GetBot();
	
	local enemy=npcBot.Target;
	local ability=npcBot:GetAbilityByName(Abilities[4]);
	
	if ability==nil or (not ability:IsFullyCastable()) then
		return false;
	end
	
	if GetUnitToUnitDistance(npcBot.Target,npcBot)<ability:GetCastRange()-100 then
		npcBot:Action_UseAbilityOnEntity(ability,npcBot.Target);
		return true;
	end
	
	return false;
end

function Think()
	mode_generic_attack.Think();
	
	local npcBot=GetBot();
	
	if not npcBot.IsAttacking or npcBot.Target==nil then
		return;
	end
	
	if npcBot:IsChanneling() or npcBot:IsUsingAbility() then
		return;
	end
	
	local enemy=npcBot.Target;
	
	if UseUlt() or UseW() then
		return;
	end
	
	npcBot:Action_AttackUnit(enemy,true);
end

--------
