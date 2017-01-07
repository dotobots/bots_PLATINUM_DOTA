------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

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

local AbilityPriority = {
"shredder_reactive_armor",
"shredder_whirling_death",
"shredder_reactive_armor",
"shredder_timber_chain",
"shredder_timber_chain",
"shredder_chakram",
"shredder_reactive_armor",
"shredder_reactive_armor",
"shredder_timber_chain",
"special_bonus_exp_boost_10",--
"shredder_timber_chain",
"shredder_whirling_death",
"shredder_chakram",
"shredder_whirling_death",
"special_bonus_hp_regen_14",--
"shredder_whirling_death",
"shredder_chakram",
"special_bonus_spell_amplify_5",--
"special_bonus_strength_20"--
};

local npcBot=GetBot();

npcBot.ItemsToBuy = {
"item_stout_shield",
"item_flask",
"item_slippers",
"item_slippers",
"item_quelling_blade",
"item_boots",
"item_energy_booster",
"item_point_booster",
"item_vitality_booster",
"item_energy_booster",
"item_ring_of_regen",
"item_sobi_mask",
"item_recipe_soul_ring",
"item_recipe_bloodstone",
"item_platemail",
"item_void_stone",
"item_ring_of_health",
"item_energy_booster",
"item_vitality_booster",
"item_reaver",
"item_recipe_heart",
"item_platemail",
"item_mystic_staff",
"item_recipe_shivas_guard",
"item_vitality_booster",
"item_staff_of_wizardry",
"item_staff_of_wizardry",
"item_point_booster",
"item_vitality_booster",
"item_energy_booster",
"item_mystic_staff",
"item_cloak",
"item_ring_of_health",
"item_ring_of_regen",
"item_branches",
"item_ring_of_regen",
"item_recipe_headdress",
"item_recipe_pipe"
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

function ItemPurchaseThink()
	local npcBot = GetBot();
	
	if Utility.IsItemAvailable("item_lotus_orb") ~= nil then
		npcBot.SecretGold = 1100;
	end
	
	
	local item=Utility.IsItemAvailable("item_stout_shield");
	if item~=nil and Utility.NumberOfItems()>5 then
		npcBot:Action_SellItem(item);
	end

	
	if npcBot:GetAbilityPoints()>0 then
		LevelUp();
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