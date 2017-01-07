------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

local Abilities ={
"bloodseeker_bloodrage",
"bloodseeker_blood_bath",
"bloodseeker_thirst",
"bloodseeker_rupture"
};

local AbilityPriority = {
"bloodseeker_bloodrage",
"bloodseeker_thirst",
"bloodseeker_thirst",
"bloodseeker_blood_bath",
"bloodseeker_thirst",
"bloodseeker_rupture",
"bloodseeker_thirst",
"bloodseeker_blood_bath",
"bloodseeker_blood_bath",
--"special_bonus_attack_damage_15",
"bloodseeker_blood_bath",
"bloodseeker_bloodrage",--
"bloodseeker_rupture",--
"bloodseeker_bloodrage",
--"special_bonus_hp_150",
"bloodseeker_bloodrage",
"bloodseeker_rupture"
--"+25 Attack Speed",
--"+15 All Stats"
};

local npcBot=GetBot();

npcBot.ItemsToBuy = {
"item_stout_shield",
"item_quelling_blade",
"item_flask",
"item_slippers",
"item_slippers",
"item_boots",
"item_gloves",
"item_boots_of_elves",
"item_slippers",
"item_circlet",
"item_recipe_wraith_band",
"item_sobi_mask",
"item_ring_of_protection",
"item_shadow_amulet",
"item_claymore",
"item_blade_of_alacrity",
"item_boots_of_elves",
"item_recipe_yasha",
"item_ogre_axe",
"item_belt_of_strength",
"item_recipe_sange",
"item_ultimate_orb",
"item_recipe_silver_edge",
"item_javelin",
"item_belt_of_strength",
"item_recipe_basher",
"item_stout_shield",
"item_vitality_booster",
"item_ring_of_health",
"item_recipe_abyssal_blade",
"item_hyperstone",
"item_chainmail",
"item_platemail",
"item_recipe_assault"
};

local Talents=
{
"special_bonus_attack_damage_25",
"special_bonus_hp_250",
"special_bonus_all_stats_10",
"special_bonus_unique_bloodseeker"
}

local function LevelUp()
	local aq=npcBot:GetAbilityByName(Abilities[1]);
	local aw=npcBot:GetAbilityByName(Abilities[2]);
	local ae=npcBot:GetAbilityByName(Abilities[3]);
	local ar=npcBot:GetAbilityByName(Abilities[4]);

	if aq~=nil and aq:GetLevel()<1 then
		npcBot:Action_LevelAbility(Abilities[1]);
		return;
	end
	
	if ar~=nil and ar:CanAbilityBeUpgraded() then
		npcBot:Action_LevelAbility(Abilities[4]);
		return;
	end
	
	if ae~=nil and ae:CanAbilityBeUpgraded() then
		npcBot:Action_LevelAbility(Abilities[3]);
		return;
	end
	
	if aw~=nil and aw:CanAbilityBeUpgraded() then
		npcBot:Action_LevelAbility(Abilities[2]);
		return;
	end
	
	if aq~=nil and aq:CanAbilityBeUpgraded() and aq:GetLevel()<2 then
		npcBot:Action_LevelAbility(Abilities[1]);
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
	
	if ( npcBot.ItemsToBuy==nil or #npcBot.ItemsToBuy == 0 ) then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end

	local NextItem = npcBot.ItemsToBuy[1];

	npcBot:SetNextItemPurchaseValue( GetItemCost( NextItem ) );

	if (not IsItemPurchasedFromSecretShop(NextItem)) and (not(IsItemPurchasedFromSideShop(NextItem) and npcBot:DistanceFromSideShop()<=2200)) then
		if ( npcBot:GetGold() >= GetItemCost( NextItem ) ) then
			npcBot:Action_PurchaseItem( NextItem );
			table.remove( npcBot.ItemsToBuy, 1 );
		end
	end
end