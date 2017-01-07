------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

local Abilities={
"furion_sprout",
"furion_teleportation",
"furion_force_of_nature",
"furion_wrath_of_nature"
};

local UltDamage={
110,140,170
};

local TTHealth=0;

local function UseUlt()
	local npcBot = GetBot();
	
	local ability=npcBot:GetAbilityByName(Abilities[4]);
	if ability==nil or (not ability:IsFullyCastable()) then
		return false;
	end
		
	local WeakestEnemy=nil;
	local LowestHP=10000.0;

	for p =1,5,1 do
		local Enemy=GetTeamMember(Utility.GetOtherTeam(),p);

		if Enemy~=nil then
		
			if Enemy:IsAlive() then
				if LowestHP>Enemy:GetHealth() and Enemy:GetHealth()>0 then
					WeakestEnemy=Enemy;
					LowestHP=Enemy:GetHealth();
				end
			end
		end
	end
	
	
	if WeakestEnemy~=nil and LowestHP>=1 then
		local ultDamage = WeakestEnemy:GetActualDamage(UltDamage[ability:GetLevel()],DAMAGE_TYPE_MAGICAL);
		if LowestHP<2*ultDamage+40 then
			print("Furion is ulting for ",WeakestEnemy:GetUnitName());
			npcBot:Action_UseAbilityOnEntity(ability,WeakestEnemy);
			return;
		end
	end
	
	
	local nHeroes=0;
	local rEnemy=nil;
	for i = 0,12,1 do
		local tower=GetTower(GetTeam(), i);
		if tower~=nil and tower:IsAlive() then
			for p =1,5,1 do
				local Enemy=GetTeamMember(Utility.GetOtherTeam(),p);
				if Enemy~=nil and Enemy:IsAlive() and GetUnitToUnitDistance(tower,Enemy) <= Max(900,Enemy:GetAttackRange()) then
					nHeroes=nHeroes+1;
					rEnemy=Enemy;
				end
			end
		end
	end
	
	if (nHeroes>1 and rEnemy~=nil) then
		npcBot:Action_UseAbilityOnEntity(ability,rEnemy)
		return;
	end
end

local function UseQ()
	local npcBot=GetBot();
	
	local ability=npcBot:GetAbilityByName(Abilities[1]);
	if not ability:IsFullyCastable() then
		return;
	end
	
	local enemy,health=Utility.GetWeakestHero(ability:GetCastRange()-75);
	if enemy==nil then
		return;
	end

	local creeps=npcBot:GetNearbyCreeps(ability:GetCastRange(),true);
	if (creeps==nil or #creeps==0) and GetUnitToUnitDistance(npcBot,enemy)>250 then
		npcBot:Action_UseAbilityOnEntity(ability,enemy);
		return;
	end
end

local function ComboIsReady()
	local npcBot=GetBot();

	local aq=npcBot:GetAbilityByName(Abilities[1]);
	local aw=npcBot:GetAbilityByName(Abilities[2]);
	if aq==nil or (not aq:IsFullyCastable()) or aw==nil or (not aw:IsFullyCastable()) then
		return false;
	end
	
	if npcBot:GetMana()<aq:GetManaCost()+aw:GetManaCost() then
		return false;
	end
	
	return true;
end

local TrashTalk=
{
[6]="заткнуться Zeus",
[767]="STOP FULJIKING BIIJCHING HEFH:OHEF"
}

local TrashTalkHero=
{
[1]="zuus",
[3]="zuus",
[4]="zuus",
[6]="zuus",
[8]="bloodseeker",
[10]="bloodseeker",
[550]="shredder",
[767]="zuus"
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
	local npcBot=GetBot();
	
	if npcBot:GetActiveMode()==BOT_MODE_RETREAT and (Utility.IsItemInInventory("item_invis_sword") or Utility.IsItemInInventory("item_silver_edge")) then
		return;
	end
	
	if npcBot:GetActiveMode()==BOT_MODE_RETREAT and ComboIsReady() then
		return;
	end
	
	UseQ();
	UseUlt();
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
	Utility.DropJunks();
end

function BuybackUsageThink()
end

