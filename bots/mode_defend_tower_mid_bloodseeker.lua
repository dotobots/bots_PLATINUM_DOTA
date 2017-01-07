------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_defend_tower_mid_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local Abilities ={
"bloodseeker_bloodrage",
"bloodseeker_blood_bath",
"bloodseeker_thirst",
"bloodseeker_rupture"
};

function OnStart()
	mode_generic_defend_tower_mid.OnStart();
end

function OnEnd()
	mode_generic_defend_tower_mid.OnEnd();
end

local function GetBestTower()
	local npcBot=GetBot();

	local BestTower=nil;
	local BestScore=0;
	
	local ignoredTowers={};	
	if GetTeam()==TEAM_RADIANT then
		ignoredTowers={Utility.GetLaneTower(GetTeam(),LANE_TOP,1),Utility.GetLaneTower(GetTeam(),LANE_TOP,2)};
	else
		ignoredTowers={Utility.GetLaneTower(GetTeam(),LANE_BOT,1),Utility.GetLaneTower(GetTeam(),LANE_BOT,2)};
	end
	
	
	for _,lane in pairs(Utility.Lanes) do
		for i = 1,4,1 do
			local Score=0;
			local tower=Utility.GetLaneTower(GetTeam(),lane,i);
			
			local isIgnored=false;
			
			if Utility.NotNilOrDead(tower) then
				for _,t in pairs(ignoredTowers) do
					if Utility.NotNilOrDead(t) then
						if t:GetUnitName()==tower:GetUnitName() then
							isIgnored=true;
						end
					end
				end
			end
			
			if Utility.NotNilOrDead(tower) and (not isIgnored) then
				for j=1,5,1 do
					local enemy=GetTeamMember(Utility.GetOtherTeam(),j);
					if Utility.NotNilOrDead(enemy) and enemy:CanBeSeen() then
						if GetUnitToLocationDistance(tower,enemy:GetLastSeenLocation())<1100 and enemy:GetTimeSinceLastSeen()<20 then
							Score=Score + 5 + i*i;
						end
					end
				end
			end
			
			if Score>BestScore then
				BestScore=Score;
				BestTower=tower;
			end
		end
	end
	
	return BestTower,BestScore;
end

function GetDesire()
	local npcBot=GetBot();
	
	if npcBot.IsDefedingTower==nil then
		npcBot.IsDefedingTower=false;
		return;
	end
	
	if npcBot.IsDefedingTower then
		return 0.46;
	end
	
	local ability=npcBot:GetAbilityByName(Abilities[2]);
	
	if ability==nil or (not ability:IsFullyCastable()) then
		npcBot.IsDefedingTower=false;
		return 0.0;
	end
	
	local BestTower=nil;
	local BestScore=0;
	
	BestTower,BestScore = GetBestTower();
	
	if BestTower~=nil and BestScore>12 then
		npcBot.IsDefedingTower=true;
		npcBot:Action_Chat("Defending",false);
		return 0.46;
	end

	npcBot.IsDefedingTower=false;
	return 0.0;
end

function Think()
	local npcBot=GetBot();
	
	local tower=nil;
	local score=0;
	
	local ability=npcBot:GetAbilityByName(Abilities[2]);
	
	if ability==nil or (not ability:IsFullyCastable()) then
		npcBot.IsDefedingTower=false;
		return;
	end
	
	tower,score = GetBestTower();
	
	if tower==nil or score<9 then
		npcBot.IsDefedingTower=false;
		return;
	end
	
	local dest=Utility.VectorTowards(tower:GetLocation(),Utility.Fountain(GetTeam()),600);
	
	if GetUnitToLocationDistance(npcBot,dest)<400 then
		local Enemies=npcBot:GetNearbyHeroes(1500,true,BOT_MODE_NONE);
		
		if Enemies==nil or #Enemies==0 then
			return;
		end
		
		local center = Utility.GetCenter(Enemies);
		
		npcBot:Action_UseAbilityOnLocation(ability,center);
		
		return;
	end
	
	npcBot:Action_MoveToLocation(dest);
end

--------
