------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

Utility = require( GetScriptDirectory().."/Utility");

local Abilities={
"zuus_arc_lightning",
"zuus_lightning_bolt",
"zuus_static_field",
"zuus_thundergods_wrath"
};

local UltDamage={225,325,425};

local function UltKills(unit,damage)
	local npcBot=GetBot();

	local ar=npcBot:GetAbilityByName(Abilities[4]);
	if ar:IsFullyCastable() and unit:GetActualDamage(UltDamage[ar:GetLevel()]+damage,DAMAGE_TYPE_MAGICAL) > unit:GetHealth() then
		return true;
	end
end

local function GetComboMana()
	local npcBot=GetBot();
	
	local aq=npcBot:GetAbilityByName(Abilities[1]);
	local aw=npcBot:GetAbilityByName(Abilities[2]);
	local ar=npcBot:GetAbilityByName(Abilities[4]);
	
	if aq:GetLevel()<1 or aw:GetLevel()<1 or ar:GetLevel()<1 then
		return 10000;
	end
	
	return aq:GetManaCost()+aw:GetManaCost()+ar:GetManaCost();
end

local function ConsiderCombo()
	local npcBot=GetBot();
	
	local aq=npcBot:GetAbilityByName(Abilities[1]);
	local aw=npcBot:GetAbilityByName(Abilities[2]);
	local ar=npcBot:GetAbilityByName(Abilities[4]);
	
	if aq:GetLevel()<1 or aw:GetLevel()<1 or ar:GetLevel()<1 then
		return false;
	end
	return true;
end


local function UseUlt()
	local npcBot=GetBot();
	
	local ability=npcBot:GetAbilityByName(Abilities[4]);
	if not ability:IsFullyCastable() then
		return;
	end
	
	local WeakestEnemy=nil;
	local LowestHP=10000.0;
	
	for p=1,5,1 do
		local Enemy=GetTeamMember(Utility.GetOtherTeam(),p);

		if Enemy~=nil then
		
			if Enemy:IsAlive() then
--				print(Enemy:GetUnitName(),Enemy:GetHealth());	
				if LowestHP>Enemy:GetHealth() and Enemy:GetHealth()>0 then
					WeakestEnemy=Enemy;
					LowestHP=Enemy:GetHealth();
				end
			end
		end
	end
	
--	print(npcBot:GetUnitName(),LowestHP);
	
	if WeakestEnemy==nil or LowestHP<1 then
		return;
	end
--	print(WeakestEnemy:GetUnitName());
	
	local ultDamage=WeakestEnemy:GetActualDamage(UltDamage[ability:GetLevel()],DAMAGE_TYPE_MAGICAL);
--	print(ultDamage);
	
	if LowestHP<=ultDamage then
--		print("Zeus is ulting for ",WeakestEnemy:GetUnitName());
		npcBot:Action_UseAbility(ability);
	end
end

local function UseQ()
	local npcBot = GetBot();
	
	local ability=npcBot:GetAbilityByName(Abilities[1]);
	if not ability:IsFullyCastable() then
		return;
	end
	
	local damage=ability:GetAbilityDamage();
	
	local enemy=nil;
	local health=10000;
	
	enemy,health=Utility.GetWeakestHero(ability:GetCastRange());
	if enemy~=nil and (health<enemy:GetActualDamage(damage,DAMAGE_TYPE_MAGICAL)*2 or UltKills(enemy,damage)) then
		npcBot:Action_UseAbilityOnEntity(ability,enemy);
		return;
	end
	
	local creep=nil;
	local chealth=10000;
	
	creep,chealth=Utility.GetWeakestCreep(ability:GetCastRange());
	if creep~=nil and chealth<creep:GetActualDamage(damage,DAMAGE_TYPE_MAGICAL) then
		if Utility.GetDistance(creep:GetLocation(),npcBot:GetLocation())>npcBot:GetAttackRange()+150 and (npcBot:GetMana()/npcBot:GetMaxMana()>0.65 or npcBot:GetMana()>=GetComboMana()) then
			npcBot:Action_UseAbilityOnEntity(ability,creep);
			return;
		end
	end
	
	if enemy~=nil and npcBot:GetMana()/npcBot:GetMaxMana()>0.50 and RandomInt(0,(1.1-npcBot:GetMana()/npcBot:GetMaxMana())*500)==0 then
		npcBot:Action_UseAbilityOnEntity(ability,enemy);
		return;
	end
end

local function UseW()
	local npcBot = GetBot();
	
	local ability=npcBot:GetAbilityByName(Abilities[2]);
	if not ability:IsFullyCastable() then
		return;
	end
	
	local damage=ability:GetAbilityDamage();
	
	local enemy=nil;
	local health=10000;
	
	enemy,health=Utility.GetWeakestHero(ability:GetCastRange()+100);
	
	if enemy==nil then
		return;
	end
	
	if GetComboMana()<=npcBot:GetMana() and UltKills(enemy,damage+60) then
		npcBot:Action_UseAbilityOnEntity(ability,enemy);
		return;
	end
	
	if enemy~=nil and health<enemy:GetActualDamage(damage,DAMAGE_TYPE_MAGICAL)+50 then
--		print("Zeus is using W on ",enemy:GetUnitName());
		npcBot:Action_UseAbilityOnEntity(ability,enemy);
		return;
	end
	
	if enemy~=nil and (npcBot:GetMana()/npcBot:GetMaxMana()>0.9 or GetComboMana()<=npcBot:GetMana()-ability:GetManaCost()) and ability:GetLevel()>1 then
--		print("Zeus is using W on ",enemy:GetUnitName());
		npcBot:Action_UseAbilityOnEntity(ability,enemy);
		return;
	end
end

local TrashTalk=
{
[1]="OMFG we have a jungler and a cliff jungler",
[3]="GG ff",
[764]="is our furion feeding again?",
[620]="we dont have a support...",
[630]="no one ganks my lane ..."
}

local TrashTalkHero=
{
[1]="zuus",
[3]="zuus",
[8]="bloodseeker",
[10]="bloodseeker",
[550]="shredder",
[764]="furion",
[620]="zuus",
[630]="zuus"
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
	
	if npcBot.PrevGold==nil then
		npcBot.PrevGold=npcBot:GetGold();
	end
	
	if npcBot:GetGold()-npcBot.PrevGold>281 then
		npcBot:Action_Chat("?",true);
	end
	
	npcBot.PrevGold=npcBot:GetGold();
end

-----------
function AbilityUsageThink()
	local npcBot=GetBot();

	UseUlt();
	if npcBot:GetActiveMode()==BOT_MODE_RETREAT then
		return;
	end
	UseQ();
	UseW();
	
end

function CourierUsageThink()
	ShitTalk();
	local npcBot=GetBot();
	if (npcBot:IsAlive() and (npcBot:GetStashValue()>900 or npcBot:GetCourierValue()>0 or Utility.HasRecipe()) and IsCourierAvailable()) then
		npcBot:Action_CourierDeliver();
	end
end


function ItemUsageThink()
	Utility.UseItems();
end


function BuybackUsageThink()
end
