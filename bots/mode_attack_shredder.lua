------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_attack_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local Abilities ={
"shredder_whirling_death",
"shredder_timber_chain",
"shredder_reactive_armor",
"shredder_chakram",
"shredder_return_chakram",
"shredder_chakram_2",
"shredder_return_chakram_2"
};

local ultTimer=10000;
local ultLocation=nil;
local ulted=false;
local ultDuration=2;

function OnStart()
	mode_generic_attack.OnStart();
	local npcBot=GetBot();
	if npcBot.Ulted==nil then
		ulted=false;
		npcBot.Ulted=false;
		
		ultTimer=-10000;
		npcBot.UltTimer=-10000;
		
		ultLocation=nil;
		npcBot.UltLocation=nil;
	else
		ulted=npcBot.Ulted;
		ultTimer=npcBot.UltTimer;
		ultLocation=npcBot.UltLocation;
	end
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
	
	local hitRadios=100;
	
	local enemy=npcBot.Target;
	
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

local function UseUlt()
	local npcBot=GetBot();
	
	local enemy=npcBot.Target;
	local ability=npcBot:GetAbilityByName(Abilities[4]);
		
	if ulted and DotaTime()-ultTimer<ultDuration then
		return false;
	end
	
	local Enemies=npcBot:GetNearbyHeroes(1400,true,BOT_MODE_NONE);
	
	if ulted then
		local nEn=0;
		for _,hero in pairs(Enemies) do
			if GetUnitToLocationDistance(hero,ultLocation)<180 then
				nEn=nEn+1;
			end
		end
		if nEn==0 or npcBot:GetMana()<100 then
			local ret=npcBot:GetAbilityByName(Abilities[5]);
			if ret~=nil and ret:IsFullyCastable() and (not npcBot:IsChanneling()) and (not npcBot:IsUsingAbility()) and (not npcBot:IsSilenced()) and (not npcBot:IsStunned()) then
				npcBot:Action_UseAbility(ret);
				ulted=false;
				ultTimer=-10000;
				ultLocation=nil;
			
				npcBot.Ulted=ulted;
				npcBot.UltTimer=ultTimer;
				npcBot.UltLocation=ultLocation;
			end
			return true;
		end
		return false;
	end
	
	if ability==nil or (not ability:IsFullyCastable()) then
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
	
	ultTimer=DotaTime();
	ulted=true;
	ultLocation=dest;
	
	npcBot.UltTimer=DotaTime();
	npcBot.Ulted=true;
	npcBot.UltLocation=dest;
	
	return true;
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
