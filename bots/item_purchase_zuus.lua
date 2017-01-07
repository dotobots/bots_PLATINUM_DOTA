------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

----------
Utility = require( GetScriptDirectory().."/Utility")
----------

local npcBot=GetBot();

local Talents =
{
"special_bonus_mp_regen_2",
"special_bonus_armor_5",
"special_bonus_movement_speed_35",
"special_bonus_unique_zeus"
}

npcBot.ItemsToBuy = {
"item_mantle",
"item_circlet",
"item_recipe_null_talisman",
"item_flask",
"item_boots",
"item_energy_booster",
"item_helm_of_iron_will",
"item_mantle",
"item_circlet",
"item_recipe_null_talisman",
"item_recipe_veil_of_discord",
"item_ring_of_health",
"item_energy_booster",
"item_recipe_aether_lens",
"item_staff_of_wizardry",
"item_ring_of_regen",
"item_recipe_force_staff",
"item_point_booster",
"item_vitality_booster",
"item_energy_booster",
"item_mystic_staff",
"item_shadow_amulet",
"item_claymore"
};

local function LevelUp()
	if #Talents==0 then
		return;
	end
    
	local npcBot = GetBot();
	
	if DotaTime()<0 then
		return;
	end
	
	local ability=npcBot:GetAbilityByName(Talents[1]);
	
	if (ability~=nil and ability:CanAbilityBeUpgraded() and ability:GetLevel()<ability:GetMaxLevel()) then
		npcBot:Action_LevelAbility(Talents[1]);
		table.remove( Talents, 1 );
	end
end

function ItemPurchaseThink()
	local npcBot = GetBot();
	
	if npcBot:GetAbilityPoints()>0 then
		LevelUp();
	end
	
	if Utility.IsItemAvailable("item_aether_lens")~=nil then
		npcBot.SecretGold=2300;
	end

	if ( npcBot.ItemsToBuy==nil or #npcBot.ItemsToBuy == 0 ) then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end

	local NextItem = npcBot.ItemsToBuy[1];

	npcBot:SetNextItemPurchaseValue( GetItemCost( NextItem ) );

	if (not IsItemPurchasedFromSecretShop( NextItem)) and (not(IsItemPurchasedFromSideShop(NextItem) and npcBot:DistanceFromSideShop()<=2200)) then
		if ( npcBot:GetGold() >= GetItemCost( NextItem ) ) then
			npcBot:Action_PurchaseItem( NextItem );
			table.remove( npcBot.ItemsToBuy, 1 );
		end
	end
end