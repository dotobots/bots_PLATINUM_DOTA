------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
_G._savedEnv = getfenv()
module( "mode_generic_rune", package.seeall )
----------
Utility = require( GetScriptDirectory().."/Utility")
----------

function  OnStart()
end

function OnEnd()
end

function GetDesire()
	local npcBot=GetBot();
	
	local creeps=npcBot:GetNearbyCreeps(450,true);
	if creeps~=nil and #creeps>0 then
		return 0.0;
	end
	
	for _,r in pairs(Utility.RuneSpots) do
		local loc=GetRuneSpawnLocation(r);
		if Utility.GetDistance(npcBot:GetLocation(),loc)<900 and GetRuneStatus(r)==RUNE_STATUS_AVAILABLE then
			return 0.35;
		end
	end

	return 0.0;
end

function Think()
	local npcBot=GetBot();
	
	for _,r in pairs(Utility.RuneSpots) do
		local loc=GetRuneSpawnLocation(r);
		if Utility.GetDistance(npcBot:GetLocation(),loc)<900 and GetRuneStatus(r)==RUNE_STATUS_AVAILABLE then
			npcBot:Action_PickUpRune(r);
			return;
		end
	end
end

--------
for k,v in pairs( mode_generic_rune ) do	_G._savedEnv[k] = v end
