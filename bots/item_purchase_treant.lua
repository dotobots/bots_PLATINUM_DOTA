------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

Utility = require(GetScriptDirectory().."/Utility")


local AbilityPriority = {
"treant_leech_seed",
"treant_living_armor",
"treant_living_armor",
"treant_natures_guise",
"treant_living_armor",
"treant_overgrowth",
"treant_living_armor",
"treant_natures_guise",
"treant_natures_guise",
"special_bonus_attack_speed_30",--
"treant_natures_guise",
"treant_leech_seed",
"treant_overgrowth",
"treant_leech_seed",
"special_bonus_gold_income_15",--
"treant_leech_seed",
"treant_overgrowth",
"special_bonus_attack_damage_65",--
"special_bonus_unique_treant"--
};

local npcBot=GetBot();

npcBot.ItemsToBuy = {
"item_courier",
"item_flask",
"item_wind_lace",
"item_boots",
"item_staff_of_wizardry",
"item_ring_of_regen",
"item_recipe_force_staff",
"item_energy_booster",
"item_gauntlets",
"item_circlet",
"item_recipe_bracer",
"item_sobi_mask",
"item_recipe_ancient_janggo",
"item_ring_of_protection",
"item_sobi_mask",
"item_ring_of_regen",
"item_branches",
"item_recipe_headdress",
"item_lifesteal"
};


local function LevelUp()
	if #AbilityPriority==0 then
		return;
	end
    
	local npcBot = GetBot();
	
	if DotaTime()<0 then
		return;
	end
	
	local ability=npcBot:GetAbilityByName(AbilityPriority[1]);
	
	if (ability~=nil and ability:CanAbilityBeUpgraded() and ability:GetLevel()<ability:GetMaxLevel()) then
		npcBot:Action_LevelAbility(AbilityPriority[1]);
		table.remove( AbilityPriority, 1 );
	end
end

local hasUpgradedCourier=false;

function ItemPurchaseThink()
	local npcBot = GetBot();
	
	if npcBot:GetAbilityPoints()>0 then
		LevelUp();
	end
	
	if DotaTime()>300 and npcBot:GetGold()>=GetItemCost("item_flying_courier") and (not hasUpgradedCourier) then
		local info=npcBot:Action_PurchaseItem("item_flying_courier");
		if info ~=nil then
			print('treant has upgraded the courier.',info);
			hasUpgradedCourier=true;
		end
	end
	
	if npcBot:GetGold()>=75 then
		npcBot:Action_PurchaseItem("item_ward_observer");
	end
	
	if ( npcBot.ItemsToBuy==nil or #npcBot.ItemsToBuy == 0 ) then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end
	
	if Utility.NumberOfItems()>=5 and Utility.IsItemAvailable("item_ward_observer")==nil then
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