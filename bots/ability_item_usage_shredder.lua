------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

Utility = require( GetScriptDirectory().."/Utility");

local Dur=0;
local UltTimer=-1000;
local UltDuration=12;
local UltRetTimer=-10000;

local Abilities ={
"shredder_whirling_death",
"shredder_timber_chain",
"shredder_reactive_armor",
"shredder_chakram",
"shredder_return_chakram",
"shredder_chakram_2",
"shredder_return_chakram_2"
};

local function UseQ()
	local npcBot=GetBot();
	
	local ability=npcBot:GetAbilityByName(Abilities[1]);
	
	if ability==nil or (not ability:IsFullyCastable()) then
		return;
	end
	
	local Enemies=npcBot:GetNearbyHeroes(290,true,BOT_MODE_NONE);
	if Enemies~=nil and (#Enemies) > 0 and (npcBot:GetMana() > 100 + ability:GetManaCost()) then
		npcBot:Action_UseAbility(ability);
		return;
	end
end

local function UseW(Enemy)
	local npcBot=GetBot();

	local ability=npcBot:GetAbilityByName(Abilities[2]);
	if ability==nil or (not ability:IsFullyCastable()) then
		return false;
	end
	
	if GetUnitToUnitDistance(npcBot,Enemy)>ability:GetCastRange() then
		return false;
	end
	
	local hitRadios=100;
	
	local enemy=Enemy;
	
	if GetUnitToUnitDistance(npcBot,enemy) > ability:GetCastRange() then
		return false;
	end
	
	if Utility.AreTreesBetween(enemy:GetLocation(),hitRadios) then
		return false;
	end
	
	--find a tree behind enemy
	local bestTree=nil;
	local mindis=10000;

	local trees=npcBot:GetNearbyTrees(ability:GetCastRange());
	
	for _,tree in pairs(trees) do
		local x=GetTreeLocation(tree);
		local y=npcBot:GetLocation();
		local z=enemy:GetLocation();
		
		if x~=y then
			local a=1;
			local b=1;
			local c=0;
		
			if x.x-y.x ==0 then
				b=0;
				c=-x.x;
			else
				a=-(x.y-y.y)/(x.x-y.x);
				c=-(x.y + x.x*a);
			end
		
			local d = math.abs((a*z.x+b*z.y+c)/math.sqrt(a*a+b*b));
			if d<=hitRadios and mindis>GetUnitToLocationDistance(enemy,x) and (GetUnitToLocationDistance(enemy,x)<=GetUnitToLocationDistance(npcBot,x)) then
				bestTree=tree;
				mindis=GetUnitToLocationDistance(enemy,x);
			end
		end
	end
	
	if bestTree~=nil then
		npcBot:Action_UseAbilityOnLocation(ability,GetTreeLocation(bestTree));
		return true;
	end
	
	return false;
end



local function UseUlt(Enemy)
	local npcBot=GetBot();
	
	local enemy=Enemy;
	local ability=npcBot:GetAbilityByName(Abilities[4]);
		
	if npcBot.Ulted then
		return false;
	end
	
	if ability==nil or (not ability:IsFullyCastable()) then
		return false;
	end
	
	if GetUnitToUnitDistance(enemy,npcBot)>ability:GetCastRange() then
		return false;
	end
	
	local v=enemy:GetVelocity();
	local sv=Utility.GetDistance(Vector(0,0),v);
	if sv>800 then
		v=(v / sv) * enemy:GetCurrentMovementSpeed();
	end
	
	
	local x=npcBot:GetLocation();
	local y=enemy:GetLocation();

--	npcBot:Action_Chat(tostring(Utility.GetDistance(Vector(0,0),v)).."  "..tostring(enemy:GetMovementDirectionStability()),false);
	
	local s=900;------------Chakram speed
	
	local a=v.x*v.x + v.y*v.y - s*s;
	local b=-2*(v.x*(x.x-y.x) + v.y*(x.y-y.y));
	local c= (x.x-y.x)*(x.x-y.x) + (x.y-y.y)*(x.y-y.y);
	
	
	local t=math.max((-b+math.sqrt(b*b-4*a*c))/(2*a) , (-b-math.sqrt(b*b-4*a*c))/(2*a));
	
	local dest = (t+0.35)*v + y;
	
	if GetUnitToLocationDistance(npcBot,dest)>ability:GetCastRange() or npcBot:GetMana()<100+ability:GetManaCost() then
		return false;
	end
	
	if enemy:GetMovementDirectionStability()<0.4 or ((not Utility.IsFacingLocation(enemy,Utility.Fountain(Utility.GetOtherTeam()),60)) and enemy:GetHealth()/enemy:GetMaxHealth()<0.4) then
		dest=Utility.VectorTowards(y,Utility.Fountain(Utility.GetOtherTeam()),180);
	end
	
	local rod=Utility.IsItemAvailable("item_rod_of_atos");
	if rod~=nil and rod:IsFullyCastable() then
		dest=enemy:GetLocation();
	end
	
	npcBot:Action_UseAbilityOnLocation(ability,dest);
	
	npcBot.UltTimer=DotaTime();
	npcBot.Ulted=true;
	npcBot.UltLocation=dest;
	
	return true;
end

local function RetUlt()
	local npcBot=GetBot();
	
	
	if npcBot.Ulted==nil then
		return false;
	end
	
	if not npcBot.Ulted and DotaTime()-UltRetTimer>1 then
		UltRetTimer=DotaTime();
		local ret=npcBot:GetAbilityByName(Abilities[5]);
		if ret:IsFullyCastable() then
			npcBot:Action_UseAbility(ret);
		end
		return false;
	end
	
	if DotaTime()-npcBot.UltTimer<2 then
		return false;
	end
	
	local Enemies=npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	if npcBot.Ulted then
		local nEn=0;
		for _,hero in pairs(Enemies) do
			if GetUnitToLocationDistance(hero,npcBot.UltLocation)<190 then
				nEn=nEn+1;
			end
		end
		if nEn==0 or npcBot:GetMana()<100 then
			local ret=npcBot:GetAbilityByName(Abilities[5]);
			if ret~=nil and ret:IsFullyCastable() and (not npcBot:IsChanneling()) and (not npcBot:IsUsingAbility()) and (not npcBot:IsSilenced()) and (not npcBot:IsStunned()) then
				npcBot:Action_UseAbility(ret);
				npcBot.Ulted=false;
				npcBot.UltTimer=-10000;
				npcBot.UltLocation=nil;
				return true;
			end
		end
		return false;
	end
end

local TrashTalk=
{
[20]="shut up treant",
[700]="wait, are we bots?",
[301]="...",
[303]="shut up treant",
[1312]="shut up treant"
}

local TrashTalkHero=
{
[1]="zuus",
[3]="zuus",
[4]="zuus",
[6]="zuus",
[8]="bloodseeker",
[20]="treant",
[10]="bloodseeker",
[301]="treant",
[303]="treant",
[700]="treant",
[1312]="treant"
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
	
	RetUlt();
	
	if npcBot:IsChanneling() then
		return;
	end
	
	UseQ();
	
	local Enemies=npcBot:GetNearbyHeroes(1400,true,BOT_MODE_NONE);
	local nEn=0;
	if Enemies~=nil then
		nEn=#Enemies;
	end
	
	local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
	local nAl=1;
	if Allies~=nil then
		nAl=nAl+ #Allies;
	end
	
	local EnemyCreeps=npcBot:GetNearbyCreeps(1000,false);
	
	if (npcBot:GetMana()/npcBot:GetMaxMana()>0.65 or npcBot:GetMana()>700 or ((EnemyCreeps==nil or #EnemyCreeps==0) and npcBot:GetMana()/npcBot:GetMaxMana()>0.4)) and npcBot:GetHealth()/npcBot:GetMaxHealth()>0.65 and Enemies~=nil and nEn-nAl<2 then
		local enemy,health = Utility.GetWeakestHero(1200);
		if enemy~=nil then
			if not UseUlt(enemy) then
				UseW(enemy);
			end
		end
	end
	
	if npcBot:GetActiveMode()==BOT_MODE_RETREAT then
		return;
	end
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
