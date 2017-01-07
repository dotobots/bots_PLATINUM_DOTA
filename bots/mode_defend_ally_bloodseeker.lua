------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_defend_ally_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local Abilities ={
"bloodseeker_bloodrage",
"bloodseeker_blood_bath",
"bloodseeker_thirst",
"bloodseeker_rupture"
};

function OnStart()
	mode_generic_defend_ally.OnStart();
end

function OnEnd()
	mode_generic_defend_ally.OnEnd();
end


function GetDesire()
	local npcBot=GetBot();
	if npcBot:GetHealth()/npcBot:GetMaxHealth()<0.5 then
		return 0.0;
	end
	
	local Enemy=Utility.GetOurEnemy();
	
	if Enemy~=nil then
		return 0.4;
	end
	
	return 0.0;
end

local function UseW(Enemy)
	local npcBot=GetBot();

	local ability=npcBot:GetAbilityByName(Abilities[2]);
	if ability==nil or (not ability:IsFullyCastable()) then
		return false;
	end
	
	if GetUnitToUnitDistance(npcBot,Enemy) >1500 then
		return false;
	end
	
	npcBot:Action_UseAbilityOnLocation(ability,Enemy:GetLocation());
	
	return true;
end

function Think()
	mode_generic_defend_ally.Think();
	
	local npcBot=GetBot();
	
	local Enemy=Utility.GetOurEnemy();
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() or Enemy==nil then
		return;
	end
	
	if not UseW(Enemy) then
		npcBot:Action_AttackUnit(Enemy,true);
	end
end

--------
