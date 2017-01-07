------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_retreat_generic" )
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

function OnStart()
	mode_generic_retreat.OnStart();
end

function OnEnd()
	mode_generic_retreat.OnEnd();
end

function GetDesire()
	return mode_generic_retreat.GetDesire();
end

local function ConsiderChain()
	
	local npcBot=GetBot();
		
	local dest=nil;
	
	if GetUnitToLocationDistance(npcBot,Utility.Fountain(GetTeam())) < 2000 then
		return false;
	end
	
	local lane=npcBot.CurLane;
	if npcBot.RetreatLane~=nil then
		lane=npcBot.RetreatLane;
	end
	local lanePos=Utility.PositionAlongLane(lane);
	
	if npcBot.IsInLane==nil or npcBot.IsInLane then
		dest=GetLocationAlongLane(npcBot.CurLane,lanePos-0.06);
	else
		dest=Utility.VectorTowards(npcBot:GetLocation(),Utility.Fountain(GetTeam()),1000);
	end

	local aw=npcBot:GetAbilityByName(Abilities[2]);
	local trees=npcBot:GetNearbyTrees(aw:GetCastRange());
	
	if aw==nil or (not aw:IsFullyCastable()) or trees==nil or #trees==0 then
		return false;
	end
	
	local BestTree=nil;
	local maxdis=0;
	
	for _,tree in pairs(trees) do
		local loc=GetTreeLocation(tree);
		
		if (not Utility.AreTreesBetween(loc,100)) and GetUnitToLocationDistance(npcBot,loc)>maxdis and GetUnitToLocationDistance(npcBot,loc)<aw:GetCastRange() and Utility.GetDistance(loc,dest)<880 then
			maxdis=GetUnitToLocationDistance(npcBot,loc);
			BestTree=loc;
		end
	end
	
	if BestTree~=nil and maxdis>250 then
		npcBot:Action_UseAbilityOnLocation(aw,BestTree);
		return true;
	end
	
	return false;
end

function Think()
	if not ConsiderChain() then
		mode_generic_retreat.Think();
	end
end

--------
