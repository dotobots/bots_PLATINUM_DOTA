------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
_G._savedEnv = getfenv()
module( "mode_generic_retreat", package.seeall )
----------
Utility = require( GetScriptDirectory().."/Utility")
----------

local LanePos = 0.0;
local CurLane = LANE_BOT;
local IsInLane = true;

function  OnStart()
	local npcBot=GetBot();

	print(npcBot:GetUnitName(),' is retreating.')
	
	local mindis=10000;
	npcBot.RetreatLane=npcBot.CurLane;
	npcBot.RetreatPos=npcBot.LanePos;
	
	for i=1,3,1 do
		local thisl=Utility.PositionAlongLane(Utility.Lanes[i]);
		local thisdis=Utility.GetDistance(GetLocationAlongLane(Utility.Lanes[i],thisl),npcBot:GetLocation());
		if thisdis<mindis then
			npcBot.RetreatLane=Utility.Lanes[i];
			npcBot.RetreatPos=thisl;
			mindis=thisdis;
		end
	end
	
	if mindis>1500 then
		npcBot.IsInLane=false;
	else
		npcBot.IsInLane=true;
	end
end

function OnEnd()
	local npcBot=GetBot();
	npcBot.IsRetreating=false;
end

function GetDesire()
	local npcBot=GetBot();
	
	if npcBot:GetHealth()/npcBot:GetMaxHealth()>0.9 and npcBot:GetMana()/npcBot:GetMaxMana()>0.9 then
		npcBot.IsRetreating=false;
		return 0.0;
	end
	
	if npcBot:GetHealth()/npcBot:GetMaxHealth()>0.65 and npcBot:GetMana()/npcBot:GetMaxMana()>0.6 and GetUnitToLocationDistance(npcBot,GetLocationAlongLane(npcBot.CurLane,0))>6000 then
		npcBot.IsRetreating=false;
		return 0.0;
	end
	
	if npcBot:GetHealth()/npcBot:GetMaxHealth()>0.8 and npcBot:GetMana()/npcBot:GetMaxMana()>0.36 and GetUnitToLocationDistance(npcBot,GetLocationAlongLane(npcBot.CurLane,0))>6000 then
		npcBot.IsRetreating=false;
		return 0.0;
	end
	
	if npcBot.IsRetreating~=nil and npcBot.IsRetreating==true then
		return 0.85;
	end
	
	local Enemies=npcBot:GetNearbyHeroes(1500,true,BOT_MODE_NONE);
	local Allies=npcBot:GetNearbyHeroes(1500,false,BOT_MODE_NONE);
	local Towers=npcBot:GetNearbyTowers(900,true);
	
	local nEn=0;
	if Enemies~=nil then
		nEn=#Enemies;
	end
	
	local nAl=0;

	if Allies~=nil then
		for _,ally in pairs(Allies) do
			if Utility.NotNilOrDead(ally) then
				nAl=nAl+1;
			end
		end
	end
	
	local nTo=0;
	if Towers~=nil then
		nTo=#Towers;
	end
	
	if (npcBot:GetHealth()<(npcBot:GetMaxHealth()*0.17*(nEn-nAl+1) + nTo*110)) or ((npcBot:GetHealth()/npcBot:GetMaxHealth())<0.33) or (npcBot:GetMana()/npcBot:GetMaxMana()<0.07 and npcBot:GetActiveMode()==BOT_MODE_LANING) then
		npcBot.IsRetreating=true;
		return 0.85;
	end
	
	if (Allies==nil or #Allies<2) then
		local MaxStun=0;
		
		for _,enemy in pairs(Enemies) do
			if Utility.NotNilOrDead(enemy) and enemy:GetHealth()/enemy:GetMaxHealth()>0.4 then
				MaxStun=Max(MaxStun, Max(enemy:GetStunDuration(true) , enemy:GetSlowDuration(true)/1.5) );
			end
		end
	
		local enemyDamage=0;
		for _,enemy in pairs(Enemies) do
			if Utility.NotNilOrDead(enemy) and enemy:GetHealth()/enemy:GetMaxHealth()>0.4 then
				local damage=enemy:GetEstimatedDamageToTarget(true,npcBot,MaxStun,DAMAGE_TYPE_ALL);
				enemyDamage=enemyDamage+damage;
			end
		end
		
		if 0.6 *enemyDamage>npcBot:GetHealth() then
			npcBot.IsRetreating=true;
			return 0.85;
		end
	end
	
	return 0.0;
end

local function Updates()
	local npcBot=GetBot();
	
	npcBot.RetreatPos=Utility.PositionAlongLane(npcBot.RetreatLane);
end

local function UseForce(nextmove)
	local npcBot=GetBot();

	local force=Utility.IsItemAvailable("item_force_staff");
	
	if force~=nil and force:IsFullyCastable() and Utility.IsFacingLocation(npcBot,nextmove,25)  then
		npcBot:Action_UseAbilityOnEntity(force,npcBot);
		return false;
	end
	return true;
end

function Think()
	local npcBot=GetBot();
	
	Updates();
	
	local nextmove=GetLocationAlongLane(npcBot.RetreatLane,0.0);
	if npcBot.IsInLane then
		nextmove=GetLocationAlongLane(npcBot.RetreatLane,Max(npcBot.RetreatPos-0.03,0.0));
	end
	
	if UseForce(nextmove) then	
		npcBot:Action_MoveToLocation(nextmove);
	end
end

--------
for k,v in pairs( mode_generic_retreat ) do	_G._savedEnv[k] = v end
