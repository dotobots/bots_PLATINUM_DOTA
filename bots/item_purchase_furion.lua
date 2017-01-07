------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

Utility = require(GetScriptDirectory().."/Utility")
----------

local AbilityPriority = {
"furion_sprout",
"furion_teleportation",
"furion_sprout",
"furion_force_of_nature",
"furion_force_of_nature",
"furion_wrath_of_nature",
"furion_teleportation",
"furion_force_of_nature",
"furion_teleportation",
"special_bonus_hp_175",--
"furion_teleportation",
"furion_force_of_nature",
"furion_wrath_of_nature",
"furion_sprout",
"special_bonus_intelligence_15",--
"furion_sprout",
"furion_wrath_of_nature",
"special_bonus_attack_speed_35",--
"special_bonus_unique_furion"--
};

local npcBot=GetBot();

npcBot.ItemsToBuy = {
"item_mantle",
"item_circlet",
"item_recipe_null_talisman",
"item_flask",
"item_boots",
"item_gloves",
"item_robe",
"item_blight_stone",
"item_gloves",
"item_branches",
"item_ring_of_regen",
"item_recipe_headdress",
"item_recipe_helm_of_the_dominator",
"item_shadow_amulet",
"item_claymore",
"item_mithril_hammer",
"item_gloves",
"item_recipe_maelstrom",
"item_mithril_hammer",
"item_mithril_hammer",
"item_ultimate_orb",
"item_recipe_silver_edge",
"item_hyperstone",
"item_recipe_mjollnir",
"item_orb_of_venom",
"item_ultimate_orb",
"item_ultimate_orb",
"item_point_booster"
};

local function LevelUp()
	if #AbilityPriority==0 then
		return;
	end
	
	if DotaTime()<0 then
		return;
	end

    local npcBot = GetBot();
	
	local ability=npcBot:GetAbilityByName(AbilityPriority[1]);

	if (ability~=nil and ability:CanAbilityBeUpgraded() and ability:GetLevel()<ability:GetMaxLevel()) then
		npcBot:Action_LevelAbility(AbilityPriority[1]);
		table.remove( AbilityPriority, 1 );
	end
end

function ItemPurchaseThink()
	local npcBot = GetBot();
	
	----
	if npcBot:GetAbilityPoints()>0 then
		LevelUp();
	end
	
	local item=Utility.IsItemAvailable("item_silver_edge");
	if item~=nil then
		npcBot.SecretGold=5300;
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