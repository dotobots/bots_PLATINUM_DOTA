------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

_G._savedEnv = getfenv()
module( "mode_generic_secret_shop", package.seeall )
----------
Utility = require( GetScriptDirectory().."/Utility")
----------

function  OnStart()
	Utility.InitPath();
end

function OnEnd()
	local npcBot=GetBot();
	npcBot.IsGoingToShop=false;
	Utility.InitPath();
end

function GetDesire()
	local npcBot=GetBot();
	if npcBot.IsGoingToShop==nil then
		npcBot.IsGoingToShop=false;
	end
	
	if npcBot.IsGoingToShop then
		return 0.23;
	end
	
	if	npcBot.ItemsToBuy==nil or #(npcBot.ItemsToBuy)==0 or (npcBot:GetActiveMode()~=BOT_MODE_SECRET_SHOP and npcBot:GetActiveMode()~=BOT_MODE_LANING and npcBot:GetActiveMode()~=BOT_MODE_FARM) then
		npcBot.IsGoingToShop=false;
		return 0.0;
	end
	
	
	local NextItem=npcBot.ItemsToBuy[1];
	
	local secLoc=Utility.GetSecretShop();

	if IsItemPurchasedFromSideShop(NextItem) and npcBot:DistanceFromSideShop()<4000 and GetUnitToLocationDistance(npcBot,secLoc)>npcBot:DistanceFromSideShop() then
		npcBot.IsGoingToShop=false;
		return 0.0;
	end
	
	if IsItemPurchasedFromSecretShop(NextItem) then
		if npcBot:GetGold() >= GetItemCost( NextItem ) and (npcBot.SecretGold==nil or npcBot.SecretGold<npcBot:GetGold()) and GetUnitToLocationDistance(npcBot,Utility.Fountain(Utility.GetOtherTeam()))>5000 then
			Utility.InitPath();
			npcBot.IsGoingToShop=true;
			return 0.23;
		end
	end
	npcBot.IsGoingToShop=false;
	return 0.0;
end

function Think()
	local npcBot=GetBot();
	if	npcBot.ItemsToBuy==nil or #npcBot.ItemsToBuy==0 then
		npcBot.IsGoingToShop=false;
		return;
	end
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() then
		return;
	end
	
	local NextItem=npcBot.ItemsToBuy[1];
	
	if (not IsItemPurchasedFromSecretShop(NextItem)) or npcBot:GetGold() < GetItemCost( NextItem ) then
		npcBot.IsGoingToShop=false;
		return;
	end
	
	local secLoc=Utility.GetSecretShop();
	
	if IsItemPurchasedFromSecretShop(NextItem) then
		if GetUnitToLocationDistance(npcBot,secLoc)<250 then
			if npcBot:GetGold() >= GetItemCost( NextItem ) then
				npcBot.IsGoingToShop=false;
				npcBot:Action_PurchaseItem( NextItem );
				table.remove( npcBot.ItemsToBuy, 1 );
				Utility.InitPath();
				return;
			else
				npcBot.IsGoingToShop=false;
				return;
			end
		else
			Utility.MoveSafelyToLocation(secLoc);
			return;
		end
	end
end

--------
for k,v in pairs( mode_generic_secret_shop ) do	_G._savedEnv[k] = v end
