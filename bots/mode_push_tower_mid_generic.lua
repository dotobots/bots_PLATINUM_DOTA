------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
_G._savedEnv = getfenv()
module( "mode_generic_push_tower_mid", package.seeall )
----------
Utility = require( GetScriptDirectory().."/Utility")
----------

function  OnStart()
end

function OnEnd()
end

function GetDesire()
	local npcBot=GetBot();
	
	local Towers=npcBot:GetNearbyTowers(900,true);
	local Enemies=npcBot:GetNearbyHeroes(900,true,BOT_MODE_NONE);
	local EnemyCreeps=npcBot:GetNearbyCreeps(900,true);
	local AllyCreeps=npcBot:GetNearbyCreeps(1100,false);
	local NearAC=0;
	
	if AllyCreeps==nil then
		return 0.0;
	end
	
	if not((EnemyCreeps==nil or #EnemyCreeps==0) and (Enemies==nil or #Enemies==0)) then
		return 0.0;
	end
	
	local WeakestRacks=nil;
	local LowestHealth=10000;
	
	for i=0,5,1 do
		local racks=GetBarracks(Utility.GetOtherTeam(),i);
		if racks~=nil and racks:IsAlive() and (not racks:IsInvulnerable()) and racks:GetHealth()>0 and GetUnitToUnitDistance(racks,npcBot)<900 then
			if (not racks:IsInvulnerable()) and LowestHealth>racks:GetHealth() then
				WeakestRacks=racks;
				LowestHealth=racks:GetHealth();
			end
		end
	end
	
	
	if WeakestRacks~=nil and GetUnitToUnitDistance(WeakestRacks,npcBot)<900 then
		return 0.4;
	end
	
	if Towers==nil then
		return 0.0;
	end
	
	if Towers~=nil and #Towers>0 and AllyCreeps~=nil and #AllyCreeps>0 then
		for _,creep in pairs(AllyCreeps) do
			if GetUnitToUnitDistance(creep,Towers[1])<800 then
				NearAC=NearAC+1;
			end
		end
	else
		return 0.0;
	end
	
	if NearAC>0 and (EnemyCreeps==nil or #EnemyCreeps==0) and (Enemies==nil or #Enemies==0) then
		return 0.4;
	end

	return 0.0;
end

function Think()
	local npcBot=GetBot();

	local WeakestRacks=nil;
	local LowestHealth=10000;
	
	for i=0,5,1 do
		local racks=GetBarracks(Utility.GetOtherTeam(),i);
		if racks~=nil and racks:IsAlive() and (not racks:IsInvulnerable()) and LowestHealth>racks:GetHealth() and GetUnitToUnitDistance(racks,npcBot)<900 then
			WeakestRacks=racks;
			LowestHealth=racks:GetHealth();
		end
	end
	
	
	if WeakestRacks~=nil and GetUnitToUnitDistance(WeakestRacks,npcBot)<900 then
		npcBot:Action_AttackUnit(WeakestRacks,true);
		return;
	end
	
	local Towers=npcBot:GetNearbyTowers(900,true);
	if Towers==nil or #Towers==0 then
		return;
	end
	
	local tower=Towers[1];
	if tower==nil or (not tower:IsAlive()) then
		return;
	end
	npcBot:Action_AttackUnit(tower,true);
end

--------
for k,v in pairs( mode_generic_push_tower_mid ) do	_G._savedEnv[k] = v end
