------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_roam_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local MinHp=0.8;
local MinMana=0.4;
local MinLevel=9;

local Abilities={
"furion_sprout",
"furion_teleportation",
"furion_force_of_nature",
"furion_wrath_of_nature"
};

function OnStart()
	mode_generic_roam.OnStart();
end

function OnEnd()
	local npcBot=GetBot();

	npcBot.Target=nil;
	npcBot.MyDamage=0;
	npcBot.RoamTimer=10000;
	npcBot.IsRoaming=false;
	mode_generic_roam.OnEnd();
end

local function FindRoamTarget()
	local npcBot=GetBot();

	local BestTarget=nil;
	local OurDamage=0;
	
	for i=1,5,1 do
		local enemy=GetTeamMember(Utility.GetOtherTeam(),i);
		
		if Utility.NotNilOrDead(enemy) and enemy:CanBeSeen() and GetUnitToUnitDistance(npcBot,enemy)>2000 then
			local nTo=0;
			
			for j=0,8,1 do
				local tower=GetTower(Utility.GetOtherTeam(),j);
				if Utility.NotNilOrDead(tower) and GetUnitToUnitDistance(enemy,tower)<1400 then
					nTo=nTo+1;
				end
			end
			
			local nEn=0;
			for j=1,5,1 do
				local enemy2=GetTeamMember(Utility.GetOtherTeam(),j);
				if i~=j and Utility.NotNilOrDead(enemy2) and enemy2:GetHealth()/enemy2:GetMaxHealth()>0.33 and GetUnitToUnitDistance(enemy,enemy2)<1300 then
					nEn=nEn+1;
				end
			end
		
			local damage=npcBot:GetEstimatedDamageToTarget(true,enemy,4.5,DAMAGE_TYPE_ALL);
			local score=0;
			for j=1,5,1 do
				
				local Ally=GetTeamMember(GetTeam(),j);
				if Utility.NotNilOrDead(Ally) and Ally:GetHealth()/Ally:GetMaxHealth()>0.6 and Ally:GetMana()/Ally:GetMaxMana()>0.4 and Ally.Target~=nil and Ally.Target:GetUnitName()==enemy:GetUnitName() and GetUnitToUnitDistance(Ally,enemy)<1100 and Ally.AttackScore~=nil and Ally.AttackScore>0.4 
					and (Ally:GetActiveMode()==BOT_MODE_LANING or Ally:GetActiveMode()==BOT_MODE_ATTACK or Ally:GetActiveMode()==BOT_MODE_ROAM) and Utility.IsCore(Ally) then
					damage=damage+Ally.MyDamage;
					score=damage+Ally.AttackScore;
				end
			end
			
			if damage/enemy:GetHealth() > OurDamage and score>0.4 and nTo==0 and nEn<2 then
				OurDamage=damage;
				BestTarget=enemy;
			end
		end
		
	end
	
	return BestTarget,OurDamage;
end

function GetDesire()
	local npcBot=GetBot();
	
	if npcBot.IsRoaming==nil then
		npcBot.RoamTimer=10000;
		npcBot.IsRoaming=false;
	end
	
	if Utility.GetHeroLevel()~=nil and Utility.GetHeroLevel()<MinLevel then
		npcBot.IsRoaming=false;
		npcBot.RoamTimer=10000;
		return 0.0;
	end
	
	if npcBot.IsRoaming then
		return 0.38;
	end
	
	local aq=npcBot:GetAbilityByName(Abilities[1]);
	local aw=npcBot:GetAbilityByName(Abilities[2]);
	
	if npcBot:GetHealth()/npcBot:GetMaxHealth()<MinHp or npcBot:GetMana()/npcBot:GetMaxMana()<MinMana or aq==nil or (not aq:IsFullyCastable()) or aw==nil or (not aw:IsFullyCastable()) then
		npcBot.IsRoaming=false;
		npcBot.RoamTimer=10000;
		return 0.0;
	end
	
	local target=nil;
	local damage=0;
	
	target,damage = FindRoamTarget();
	
	if Utility.NotNilOrDead(target) and damage>target:GetHealth() then
		npcBot.IsRoaming=true;
		npcBot.Target=target;
		npcBot.MyDamage=npcBot:GetEstimatedDamageToTarget(true,target,4.5,DAMAGE_TYPE_ALL);
		npcBot.RoamTimer=DotaTime();
		return 0.38;
	end
	
	npcBot.Target=nil;
	npcBot.IsRoaming=false;
	npcBot.RoamTimer=10000;
	return 0.0;
end

function Think()
	local npcBot=GetBot();
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling()  then
		return;
	end
	
	local enemy=npcBot.Target;
	
	if (not Utility.NotNilOrDead(enemy)) or (not npcBot:IsAlive()) or (not enemy:CanBeSeen()) or DotaTime()-npcBot.RoamTimer >30 or npcBot.IsRoaming==nil or npcBot.Target==nil or (not npcBot.IsRoaming) then
--		npcBot:Action_ClearActions();
		npcBot.IsRoaming=false;
		npcBot.Target=nil;
		npcBot.MyDamage=0;
		npcBot.RoamTimer=10000;
		return;
	end
	
	local aq=npcBot:GetAbilityByName(Abilities[1]);
	local aw=npcBot:GetAbilityByName(Abilities[2]);
	
	if (aw==nil or (not aw:IsFullyCastable())) and GetUnitToUnitDistance(npcBot,enemy)>1500 then
		npcBot.IsRoaming=false;
		npcBot.Target=nil;
		npcBot.MyDamage=0;
		
		return;
	end
	
	if aw~=nil and aw:IsFullyCastable() and GetUnitToUnitDistance(npcBot,enemy)>2000 then
		local dest=Utility.VectorTowards(enemy:GetLocation(), Utility.Fountain(Utility.GetOtherTeam()), 650);
		npcBot:Action_UseAbilityOnLocation(aw, dest);
		return;
	end
	
	npcBot.IsRoaming=false;
	npcBot.Target=nil;
	npcBot.MyDamage=0;
	npcBot.RoamTimer=10000;
end

--------
