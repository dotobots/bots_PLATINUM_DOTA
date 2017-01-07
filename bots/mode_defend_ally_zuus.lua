------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_defend_ally_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local Abilities={
"zuus_arc_lightning",
"zuus_lightning_bolt",
"zuus_static_field",
"zuus_thundergods_wrath"
};

function OnStart()
	mode_generic_defend_ally.OnStart();
end

function OnEnd()
	mode_generic_defend_ally.OnEnd();
end

local function UseQ(Enemy)
	local npcBot = GetBot();
	
	local ability=npcBot:GetAbilityByName(Abilities[1]);
	if not ability:IsFullyCastable() then
		return false;
	end
	
	local damage=ability:GetAbilityDamage();
	
	local enemy=Enemy;
	
	if GetUnitToUnitDistance(npcBot,Enemy)>ability:GetCastRange() then
		return false;
	end
	
	if enemy~=nil and npcBot:GetMana()/npcBot:GetMaxMana()>0.40 then
		npcBot:Action_UseAbilityOnEntity(ability,enemy);
		return true;
	end
end

local function UseW(Enemy)
	local npcBot = GetBot();
	
	local ability=npcBot:GetAbilityByName(Abilities[2]);
	if not ability:IsFullyCastable() then
		return false;
	end
	
	local enemy=Enemy;
	
	if GetUnitToUnitDistance(npcBot,Enemy)<ability:GetCastRange() then
		npcBot:Action_UseAbilityOnEntity(ability,enemy)
		return true;
	end
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

function Think()
	mode_generic_defend_ally.Think();
	
	local npcBot=GetBot();
	
	local Enemy=Utility.GetOurEnemy();
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() or Enemy==nil then
		return;
	end
	
	if (not UseW(Enemy)) and (not UseQ(Enemy)) then
		npcBot:Action_AttackUnit(Enemy,true);
	end
end

--------
