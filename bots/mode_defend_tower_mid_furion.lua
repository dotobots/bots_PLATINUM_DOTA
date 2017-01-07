------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_defend_tower_mid_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local Abilities={
"furion_sprout",
"furion_teleportation",
"furion_force_of_nature",
"furion_wrath_of_nature"
};


local function GetBestTower()
	local npcBot=GetBot();

	local BestTower=nil;
	local NearbyEnemies=10;
	local BestLane=nil;
	
	for _,lane in pairs(Utility.Lanes) do
		for i = 1,4,1 do
			local nEn=0;
			local nAl=0;
			local tower=Utility.GetLaneTower(GetTeam(),lane,i);
			
			local laneloc=GetLocationAlongLane(lane,GetLaneFrontAmount(Utility.GetOtherTeam(),lane,true));
			
			if Utility.NotNilOrDead(tower) and GetUnitToLocationDistance(tower,laneloc)<600 and lane~=npcBot.CurLane then
				for j=1,5,1 do
					local ally=GetTeamMember(GetTeam(),j);
					if ally.CurLane~=nil and ally.CurLane==lane and Utility.IsCore(ally) then
						nAl=nAl+1;
					end
				end
			
				for j=1,5,1 do
					local enemy=GetTeamMember(Utility.GetOtherTeam(),j);
					if Utility.NotNilOrDead(enemy) and enemy:CanBeSeen() then
						if GetUnitToLocationDistance(tower,enemy:GetLastSeenLocation())<1300 and enemy:GetTimeSinceLastSeen()<20 then
							nEn=nEn+1;
						end
					end
				end
				
				if nEn<NearbyEnemies and nAl==0 then
					NearbyEnemies=nEn;
					BestTower=tower;
					BestLane=lane;
				end
			end
		end
	end
	
	return BestTower,BestLane,NearbyEnemies;
end

function OnStart()
	mode_generic_defend_tower_mid.OnStart();
end

function OnEnd()
	mode_generic_defend_tower_mid.OnEnd();
end

function GetDesire()
	local npcBot=GetBot();
	
	if npcBot.IsDefending==nil then
		npcBot.IsDefending=false;
		npcBot.DefendTimer=-1000;
		return 0.0;
	end
	
	if Utility.GetHeroLevel()~=nil and Utility.GetHeroLevel()<9 then
		return 0.0;
	end
	
	if npcBot.DefendTimer==nil then
		npcBot.DefendTimer=-1000;
	end
	
	if npcBot.IsDefending then
		return 0.4;
	end
	
	local tp=npcBot:GetAbilityByName(Abilities[2]);
	if tp==nil or (not tp:IsFullyCastable()) then
		npcBot.IsDefending=false;
		return 0.0;
	end
	
	local Tower=nil;
	local nEn=0;
	
	Tower,_ , nEn = GetBestTower();
	
	if Tower~=nil and DotaTime()-npcBot.DefendTimer>30 then
		npcBot.DefendTimer=DotaTime();
		npcBot.IsDefending=true;
		npcBot:Action_Chat("Defending",false);
		return 0.4;
	end
	
	return 0.0;
end

function Think()
	local npcBot=GetBot();

	if npcBot:IsUsingAbility() or npcBot:IsChanneling() then
		return;
	end
	
	local Tower=nil;
	local Lane=nil;
	local nEn=0;
	
	Tower, Lane, nEn = GetBestTower();
	
	if not Utility.NotNilOrDead(Tower) then
		npcBot.IsDefending=false;
		npcBot.DefendTimer=-1000;
		return;
	end
	
	local dest=Utility.VectorTowards(Tower:GetLocation(),Utility.Fountain(GetTeam()),500);

	if GetUnitToLocationDistance(npcBot,dest)<400 then
		npcBot.IsDefending=false;
		npcBot.DefendTimer=-10000;
		return;
	end
	
	local tp=npcBot:GetAbilityByName(Abilities[2]);
	if tp==nil or (not tp:IsFullyCastable()) then
		npcBot:Action_MoveToLocation(dest);
		npcBot.CurLane=Lane;
		return;
	end
	
	npcBot:Action_UseAbilityOnLocation(tp,dest);
	
	npcBot.CurLane=Lane;
end

--------
