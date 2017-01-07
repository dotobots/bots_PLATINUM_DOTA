------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
_G._savedEnv = getfenv()
module( "mode_generic_side_shop", package.seeall )
----------
Utility = require( GetScriptDirectory().."/Utility")
----------

function  OnStart()
end

function OnEnd()
end

function GetDesire()
	local npcBot=GetBot();
	if	npcBot.ItemsToBuy==nil or #(npcBot.ItemsToBuy)==0 then
		return 0.0;
	end
	
	local NextItem=npcBot.ItemsToBuy[1];
	
	local Enemies=npcBot:GetNearbyHeroes(1300,true,BOT_MODE_NONE);
	
	if IsItemPurchasedFromSideShop(NextItem) then
		if npcBot:GetGold() >= GetItemCost( NextItem ) and npcBot:DistanceFromSideShop()<2200 and (Enemies==nil or #Enemies<2 or npcBot:DistanceFromSideShop()<1100)then
			return 0.3;
		end
	end

	return 0.0;
end

function Think()
	local npcBot=GetBot();
	if	npcBot.ItemsToBuy==nil or #npcBot.ItemsToBuy==0 then
		return;
	end
	
	local NextItem=npcBot.ItemsToBuy[1];
	
	local secLoc=nil;
	if GetUnitToLocationDistance(npcBot,Utility.SIDE_SHOP_TOP)<GetUnitToLocationDistance(npcBot,Utility.SIDE_SHOP_BOT) then
		secLoc=Utility.SIDE_SHOP_TOP;
	else
		secLoc=Utility.SIDE_SHOP_BOT;
	end
	
	if secLoc==nil then
		return;
	end
	
	if IsItemPurchasedFromSideShop(NextItem) then
		if GetUnitToLocationDistance(npcBot,secLoc)<250 and npcBot:GetGold() >= GetItemCost( NextItem ) then
			npcBot:Action_PurchaseItem( NextItem );
			table.remove( npcBot.ItemsToBuy, 1 );
			return;
		else
			npcBot:Action_MoveToLocation(secLoc);
			return;
		end
	end
end

--------
for k,v in pairs( mode_generic_side_shop ) do	_G._savedEnv[k] = v end
