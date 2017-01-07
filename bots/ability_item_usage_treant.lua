------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

Utility = require( GetScriptDirectory().."/Utility")
----------

local Abilities =
{
"treant_natures_guise",
"treant_leech_seed",
"treant_living_armor",
"treant_overgrowth"
}

local function UseArmor()
	local npcBot = GetBot();
	local ability = npcBot:GetAbilityByName(Abilities[3]);
	
	if not ability:IsFullyCastable() then
		return;
	end
	
	local WeakestAlly=nil;
	local LowestHP=10000.0;
	local nEn=0;

	for p =1,5,1 do
		local Ally=GetTeamMember(GetTeam(),p);

		if Ally==nil then
			Ally=npcBot;
		end
		
		if Ally:IsAlive() then
			local Threats=Ally:GetNearbyHeroes(700,true,BOT_MODE_NONE);
			local Towers=Ally:GetNearbyTowers(950,true);
			nEn=#Threats;
	
			if LowestHP>(Ally:GetHealth()-(Ally:GetMaxHealth()*0.05)*(#Threats)-50*(#Towers)) then
				WeakestAlly=Ally;
				LowestHP=(Ally:GetHealth()-(Ally:GetMaxHealth()*0.05)*(#Threats)-50*(#Towers));
			end
		end
	end
	
--	print(LowestHP,WeakestAlly:GetMaxHealth(),WeakestAlly:GetUnitName());
	
	if Utility.NotNilOrDead(WeakestAlly) then
		if ((LowestHP<250) or (LowestHP/WeakestAlly:GetMaxHealth() < 0.43) and GetUnitToLocationDistance(WeakestAlly,Utility.Fountain(GetTeam()))>2200 ) then
			npcBot:Action_UseAbilityOnEntity(ability,WeakestAlly);
			return;
		end
		
		if LowestHP/WeakestAlly:GetMaxHealth() < 0.65 or ability:GetLevel()<3 then
			return;
		end
	end
	
	if (not Utility.NotNilOrDead(WeakestAlly)) or LowestHP/WeakestAlly:GetMaxHealth()>=0.65 then
		local WeakestTower=nil;
		local LowestHP=1;
		for i=0,11,1 do
			local tower=GetTower(GetTeam(),i);
			if tower~=nil and tower:IsAlive() and tower:GetHealth()/tower:GetMaxHealth()<LowestHP then
				LowestHP=tower:GetHealth()/tower:GetMaxHealth();
				WeakestTower=tower;
			end
		end
		
		if LowestHP<0.90 then
			npcBot:Action_UseAbilityOnEntity(ability,WeakestTower);
			return;
		end
	end
end

local function UseUlt()
	local npcBot = GetBot();
	local ability = npcBot:GetAbilityByName(Abilities[4]);
	
	if not ability:IsFullyCastable() then
		return;
	end
	
	local WeakAllies=npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_RETREAT );
	if WeakAllies~=nil and #WeakAllies>0 then
		local ClosestCenter=nil;
		local mindis=10000;
		
		for _,hero in pairs(WeakAllies) do
			local enemies=hero:GetNearbyHeroes(700,true,BOT_MODE_NONE);
			if enemies~=nil and #enemies>0 then
				local loc=Utility.GetCenter(enemies);
				
				if GetUnitToLocationDistance(npcBot,loc)<mindis then
					ClosestCenter=loc;
					mindis=GetUnitToLocationDistance(npcBot,loc);
				end
			end
		end
		if ClosestCenter~=nil then
			if mindis<400 then
				npcBot:Action_UseAbility(ability);
			else
				npcBot:Action_MoveToLocation(ClosestCenter);
			end
			return;
		end;
	end
	
	local Allies=npcBot:GetNearbyHeroes(700,false,BOT_MODE_NONE);
	if Allies==nil or #Allies==0 then
		return;
	end
	
	local isCoreAround=false;
	for _,ally in pairs(Allies) do
		if (ally~=nil and Utility.IsCore(ally)) then 
			isCoreAround=true;
		end
	end
	if not isCoreAround then
		return;
	end
	
	local enemy=nil;
	local health=100000;
	enemy,health = Utility.GetWeakestHero(800);
	if enemy==nil then
		return;
	end
	
	if health<0.35*enemy:GetMaxHealth() then
		npcBot:Action_UseAbility(ability);
	end
end

local TrashTalk=
{
[2]="...",
[17]="guys, can we all be friends?",
[22]=":(",
[298]="OMFG THIS CARRY CANT LAST HIT CREEPS",
[622]=":(",
[703]="beep boop",
[1310]="I hope we are winning ...",
[1315]="Timber HC shit talking ...",
}

local TrashTalkHero=
{
[1]="zuus",
[2]="zuus",
[3]="zuus",
[4]="zuus",
[6]="zuus",
[8]="bloodseeker",
[10]="bloodseeker",
[298]="shredder",
[17]="treant",
[22]="shredder",
[622]="zuus",
[703]="shredder",
[1310]="treant",
[1315]="shredder"
}


local function HeroIsHere(heroname)
	for i=1,5,1 do
		local Ally=GetTeamMember(GetTeam(),i);
		if Ally~=nil then
			if string.find(Ally:GetUnitName(),heroname)~=nil then
				return true;
			end
		end
	end
	
	return false;
end

local function ShitTalk()
	local npcBot=GetBot();
	
	local now = math.floor(DotaTime());
	if TrashTalk[now]~=nil and HeroIsHere(TrashTalkHero[now]) then
		npcBot:Action_Chat(TrashTalk[now],true);
		TrashTalk[now]=nil;
	end
end

function AbilityUsageThink()
	ShitTalk();
	
	local npcBot = GetBot();
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() then
		return;
	end
	
	UseArmor();
	UseUlt();
end

function CourierUsageThink()
	npcBot=GetBot();
	if (npcBot:IsAlive() and (npcBot:GetStashValue()>900 or npcBot:GetCourierValue()>0 or Utility.HasRecipe()) and IsCourierAvailable()) then
		npcBot:Action_CourierDeliver();
	end
end

function ItemUsageThink()
	Utility.UseItems();
end

function BuybackUsageThink()
end

