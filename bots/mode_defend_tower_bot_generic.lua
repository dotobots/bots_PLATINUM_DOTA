------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
_G._savedEnv = getfenv()
module( "mode_generic_defend_tower_bot", package.seeall )
----------
Utility = require( GetScriptDirectory().."/Utility")
----------
-------------
-- This is for getting back when the hero is getting hit under a tower
-------------
function  OnStart()
end

function OnEnd()
end


function GetDesire()
	local npcBot=GetBot();
	local Towers=npcBot:GetNearbyTowers(900,true);
		
	if npcBot.PrevHealth==nil then
		npcBot.PrevHealth=npcBot:GetHealth();
		npcBot.GettingHitByTower=false;
		print(npcBot:GetUnitName(),'initializing');
		return 0.0;
	end

	local hDelta=npcBot.PrevHealth-npcBot:GetHealth();
	
	npcBot.PrevHealth=npcBot:GetHealth();
	
	local td1=npcBot:GetActualDamage(100*0.85,DAMAGE_TYPE_PHYSICAL);
	local td2=npcBot:GetActualDamage(122*0.85,DAMAGE_TYPE_PHYSICAL);
	
	if Towers==nil or #Towers==0 then
		npcBot.GettingHitByTower=false;
		return 0.0;
	end
	
	if npcBot.GettingHitByTower then
		if npcBot.ShoudPush==nil or (not npcBot.ShoudPush) then
			return 0.75;
		else
			return 0.55;
		end
	end
	
	--if we are too tanky ignore this
	if (td2<=npcBot:GetMaxHealth()*0.04) and npcBot:GetHealth()>npcBot:GetMaxHealth()*0.4 then
		return 0.0;
	end	
	
	if hDelta>=td1 then
		npcBot.GettingHitByTower=true;
		if npcBot.ShoudPush==nil or (not npcBot.ShoudPush) then
			return 0.75;
		else
			return 0.55;
		end
	end

	npcBot.GettingHitByTower=false;
	return 0.0;
end

function Think()
	local npcBot=GetBot();
	
	local LanePos=Utility.PositionAlongLane(npcBot.CurLane);
	npcBot:Action_MoveToLocation(GetLocationAlongLane(npcBot.CurLane,LanePos-0.3));
end

--------
for k,v in pairs( mode_generic_defend_tower_bot ) do	_G._savedEnv[k] = v end
