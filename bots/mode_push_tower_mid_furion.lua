------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_push_tower_mid_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local Abilities={
"furion_sprout",
"furion_teleportation",
"furion_force_of_nature",
"furion_wrath_of_nature"
};

local hasUsedQ=false;

local function PushCombo(building)
	local npcBot=GetBot();

	local aq=npcBot:GetAbilityByName(Abilities[1]);
	local ae=npcBot:GetAbilityByName(Abilities[3]);
	if aq==nil or ae==nil or (not Utility.NotNilOrDead(building)) then
		hasUsedQ=false;
		return;
	end
	
	local loc=Vector(0,0);
	local isRacks=false;
	if not building:IsTower() then
		isRacks=true;
		loc=GetLocationAlongLane(npcBot.CurLane,Min(npcBot.LanePos+0.03,1.0));
	end
	
	local npcBot=GetBot();
	if hasUsedQ and ae:IsFullyCastable() and (not aq:IsFullyCastable()) then
		if not isRacks then
			npcBot:Action_UseAbilityOnLocation(ae,building:GetLocation());
			hasUsedQ=false;
		else
			npcBot:Action_UseAbilityOnLocation(ae,loc);
			hasUsedQ=false;
		end
		
		local n=RandomInt(0,8);
		if n==1 then
			npcBot:Action_Chat( 'Bloodseeker is jungling, go kill him', true);
		end
		if n==2 then
			npcBot:Action_Chat( "I'm cliff jungling, don't mind me", true);
		end
		if n==3 then
			npcBot:Action_Chat( "dogers out for Harambe", true);
		end
		return;
	end
	
	if aq:IsFullyCastable() and ae:IsFullyCastable() and (npcBot:GetMana() >= ae:GetManaCost()+aq:GetManaCost()) then
		if not isRacks then
			npcBot:Action_UseAbilityOnLocation(aq,building:GetLocation());
			hasUsedQ=true;
		else
			npcBot:Action_UseAbilityOnLocation(aq,loc);
			hasUsedQ=true;
		end
		return;
	end
end

local function CanUsePushCombo()
	if hasUsedQ then
		return true;
	end

	local npcBot=GetBot();

	local aq=npcBot:GetAbilityByName(Abilities[1]);
	local ae=npcBot:GetAbilityByName(Abilities[3]);
	
	if aq:IsFullyCastable() and ae:IsFullyCastable() and (npcBot:GetMana() >= ae:GetManaCost()+aq:GetManaCost()) then
		return true;
	end
	return false;
end

function OnStart()
	mode_generic_push_tower_mid.OnStart();
	hasUsedQ=false;
end

function OnEnd()
	mode_generic_push_tower_mid.OnEnd();
end

function GetDesire()
	return mode_generic_push_tower_mid.GetDesire();
end

function Think()
	local npcBot=GetBot();
	
	if npcBot:IsUsingAbility() then
		return;
	end
	if not CanUsePushCombo() then
		mode_generic_push_tower_mid.Think();
	end

	local WeakestRacks=nil;
	local LowestHealth=10000;
	
	for i=0,5,1 do
		local racks=GetBarracks(Utility.GetOtherTeam(),i);
		if racks~=nil and racks:IsAlive() and (not racks:IsInvulnerable()) and LowestHealth>racks:GetHealth() and GetUnitToUnitDistance(racks,npcBot)<900 then
			WeakestRacks=racks;
			LowestHealth=racks:GetHealth();
		end
	end
	
	if Utility.NotNilOrDead(WeakestRacks) then
		PushCombo(WeakestRacks);
		return;
	end
	
	local Towers=npcBot:GetNearbyTowers(750,true);
	if Towers==nil or #Towers==0 then
		return;
	end
	
	local tower=Towers[1];
	
	if tower==nil or (not tower:IsAlive()) then
		return;
	end
		
	if tower~=nil then
		if GetUnitToUnitDistance(tower,npcBot)<750 then
			PushCombo(tower);
		else
			npcBot:Action_MoveToUnit(tower);
		end
		return;
	end
end

--------
