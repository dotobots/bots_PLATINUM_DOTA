------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_defend_ally_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local Abilities={
"furion_sprout",
"furion_teleportation",
"furion_force_of_nature",
"furion_wrath_of_nature"
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

local function UseQ(Enemy)
	local npcBot=GetBot();
	
	local ability=npcBot:GetAbilityByName(Abilities[1]);
	if not ability:IsFullyCastable() then
		return;
	end

	if GetUnitToUnitDistance(npcBot,Enemy)>ability:GetCastRange() then
		return false;
	end
	
	npcBot:Action_UseAbilityOnEntity(ability,Enemy);
	
	return true;
end

function Think()
	mode_generic_defend_ally.Think();
	
	local npcBot=GetBot();
	
	local Enemy=Utility.GetOurEnemy();
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() or Enemy==nil then
		return;
	end
	
	if not UseQ(Enemy) then
		npcBot:Action_AttackUnit(Enemy,true);
	end
end

--------
