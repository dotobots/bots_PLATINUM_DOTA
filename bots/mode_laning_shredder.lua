------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_laning_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local LaningStates={
	Start=0,
	Moving=1,
	WaitingForCS=2,
	CSing=3,
	WaitingForCreeps=4,
	MovingToPos=5,
	GetReadyForCS=6,
	GettingBack=7,
	MovingToLane=8
}

local Abilities ={
"shredder_whirling_death",
"shredder_timber_chain",
"shredder_reactive_armor",
"shredder_chakram",
"shredder_return_chakram",
"shredder_chakram_2",
"shredder_return_chakram_2"
};

local aqDamage={100,150,200,250};

local CurLane = LANE_BOT;
local LaningState = LaningStates.Start;
local LanePos = 0.0;
local backTimer=-1000;
local ShouldPush=false;
local IsCore=true;
local isUsingFarmingCombo=false;
local FarmingComboTimer=-10000;

local DamageThreshold=1.0;
local MoveThreshold=1.0;

function OnStart()
	mode_generic_laning.OnStart();
	if DotaTime()>2 then
		LoadUpdates();
	end
end

function OnEnd()
	mode_generic_laning.OnEnd();
end

function GetDesire()
	return mode_generic_laning.GetDesire();
end

function GetBack()
	local npcBot=GetBot();
	
	local Enemies=npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);
	
	if Enemies== nil or #Enemies==0 then
		return true;
	end
	
	for _,enemy in pairs(Enemies) do
		if npcBot:IsSilenced() or #Enemies>3 or (GetUnitToUnitDistance(npcBot,enemy)<400 and npcBot:GetHealth()<300) or (#Enemies>1 and npcBot:GetHealth()/npcBot:GetMaxHealth()<0.43) then
			backTimer=DotaTime();
			npcBot:Action_MoveToLocation(GetLocationAlongLane(CurLane,LanePos-0.02));
			return false;
		end
		
		if DotaTime()-backTimer<1 then
			npcBot:Action_MoveToLocation(GetLocationAlongLane(CurLane,LanePos-0.02));
			return false;
		end
	end
	
	local enemy=nil;
	
	enemy,_=Utility.GetWeakestHero(npcBot:GetAttackRange());
	if enemy==nil then
		return true;
	end
	
	if GetUnitToUnitDistance(npcBot,enemy)<=600 and (Utility.GetHeroLevel()==nil or Utility.GetHeroLevel()>4) then
		npcBot:Action_AttackUnit(enemy,true);
		return false;
	end
	
	return true;
end

local function UseQ()
	local npcBot=GetBot();
	
--	if npcBot:GetHealth()/npcBot:GetMaxHealth()<0.44 then
--		return true;
--	end
	
	local ability=npcBot:GetAbilityByName(Abilities[1]);
	
	if ability==nil or (not ability:IsFullyCastable()) then
		return true;
	end
	
	local damage=aqDamage[ability:GetLevel()];

	local Creeps=npcBot:GetNearbyCreeps(1000,true);
	
	if Creeps==nil or #Creeps==0 then
		return true;
	end
			
	local WeakCreeps={};
	
	for _,creep in pairs(Creeps) do
		if creep~=nil and creep:GetHealth()<damage then
			table.insert(WeakCreeps,creep);
		end
	end
	
	if WeakCreeps==nil or #WeakCreeps==0 then
		return true;
	end
	
	local center=Utility.GetCenter(WeakCreeps);
	local nCr=0;
	
	for _,creep in pairs(WeakCreeps) do
		if GetUnitToLocationDistance(creep,center)<300 then
			nCr=nCr+1;
		end
	end
	
	if nCr>1 and npcBot:GetMana()/npcBot:GetMaxMana()>0.38 and npcBot:GetMana()>200 then
		if GetUnitToLocationDistance(npcBot,center)<130 then
			npcBot:Action_UseAbility(ability);
			return false;
		else
			npcBot:Action_MoveToLocation(center);
			return false;
		end
	end
	return true;
end

local function IsFarmingComboReady()
	npcBot=GetBot();
	
	if isUsingFarmingCombo==nil then
		isUsingFarmingCombo=false;
		return false;
	end
	
	if isUsingFarmingCombo==true then
		return true;
	end
	
	if npcBot.ShouldPush==nil or (not npcBot.ShouldPush) then
		isUsingFarmingCombo=false;
		return false;
	end
	
	if Utility.GetHeroLevel()~=nil and Utility.GetHeroLevel()<5 then
		isUsingFarmingCombo=false;
		return false;
	end
	
	local aq=npcBot:GetAbilityByName(Abilities[1]);
	local aw=npcBot:GetAbilityByName(Abilities[2]);
	local ar=npcBot:GetAbilityByName(Abilities[4]);
	
	if aq==nil or (not aq:IsFullyCastable()) or aw==nil or (not aw:IsFullyCastable()) or ar==nil or (not ar:IsFullyCastable()) then
		return false;
	end
	
	local Enemies=npcBot:GetNearbyHeroes(1400,true,BOT_MODE_NONE);
	
	local manaCost=aq:GetManaCost() + aw:GetManaCost() + ar:GetManaCost();
	if npcBot:GetMana()<3*manaCost or (Enemies~=nil and #Enemies>0) then
		isUsingFarmingCombo=false;
		return false;
	end
	
	local creeps=npcBot:GetNearbyCreeps(800,true);
	local center=Utility.GetCenterOfCreeps(creeps);
	
	local nCr=0;
	for _,creep in pairs(creeps) do
		if GetUnitToLocationDistance(creep,center)<300 and (string.find(creep:GetUnitName(),"melee")~=nil or string.find(creep:GetUnitName(),"range")~=nil or string.find(creep:GetUnitName(),"siege")) then
			nCr=nCr+1;
		end
	end
	
	if nCr<3 then
		isUsingFarmingCombo=false;
		return false;
	end
	
	isUsingFarmingCombo=true;
	FarmingComboTimer=DotaTime();
	return true;
end

local function UseFarmingCombo()
	local npcBot=GetBot();
	
	if not IsFarmingComboReady() then
		return true;
	end
	
	local aq=npcBot:GetAbilityByName(Abilities[1]);
	local aw=npcBot:GetAbilityByName(Abilities[2]);
	local ar=npcBot:GetAbilityByName(Abilities[4]);
	
	local trees=npcBot:GetNearbyTrees(900);
	
	if (aq==nil or (not aq:IsFullyCastable())) and (aw==nil or (not aw:IsFullyCastable()) or trees==nil or #trees<2) and (ar==nil or (not ar:IsFullyCastable())) then
		isUsingFarmingCombo=false;
		return true;
	end
	
	local creeps=npcBot:GetNearbyCreeps(800,true);
	local center=Utility.GetCenterOfCreeps(creeps);
	
	if center==nil then
		isUsingFarmingCombo=false;
		return true;
	end
	
	if ar~=nil and ar:IsFullyCastable() then
		npcBot:Action_UseAbilityOnLocation(ar,center);
		npcBot.Ulted=true;
		npcBot.UltTimer=DotaTime();
		npcBot.UltLocation=center;
		return false;
	end
	
	if GetUnitToLocationDistance(npcBot,center)>130 and DotaTime()-FarmingComboTimer<=4 then
		npcBot:Action_MoveToLocation(center);
		return false;
	end
	
	
	if aq~=nil and aq:IsFullyCastable() then
		npcBot:Action_UseAbility(aq);
		return false;
	end
	
	if aw~=nil and aw:IsFullyCastable() then
		local trees=npcBot:GetNearbyTrees(900);
		if trees~=nil and #trees>0 then
			for i = 0,#trees,1 do
				tree=trees[i];
				if tree~=nil then
					local loc=GetTreeLocation(tree);
					npcBot:Action_UseAbilityOnLocation(aw,loc);
					return false;
				end
			end
		end
	end
	
	isUsingFarmingCombo=false;
	return true;
end

local function Updates()
	local npcBot=GetBot();
	
	if DotaTime()<100 then
		CurLane=npcBot:GetAssignedLane();
	end
	
	if npcBot:GetHealth()/npcBot:GetMaxHealth()>0.75 and (Utility.GetHeroLevel()==nil or Utility.GetHeroLevel()>3) then
		npcBot.CreepDist=450;
		MoveThreshold=0.95;
	else
		npcBot.CreepDist=550;
		MoveThreshold=1.1;
	end
	
	if CurLane~=nil and GetUnitToLocationDistance(npcBot,GetLocationAlongLane(CurLane,0.0)) < 1000 then
		CurLane=Utility.ConsiderChangingLane(CurLane);
	end
	
	if Utility.IsItemInInventory("item_arcane_boots")~=nil and (Utility.GetHeroLevel()==nil or Utility.GetHeroLevel()>5) then
		ShouldPush=true;
	end
	
	LanePos = Utility.PositionAlongLane(CurLane);
	
	if ((not(npcBot:IsAlive())) or (LanePos<0.15 and LaningState~=LaningStates.Start)) then
		LaningState=LaningStates.Moving;
	end
end

function SaveUpdates()
	local npcBot=GetBot();
	
	npcBot.LaningState=LaningState;
	npcBot.LanePos=LanePos;
	npcBot.CurLane=CurLane;
	npcBot.MoveThreshold=MoveThreshold;
	npcBot.DamageThreshold=DamageThreshold;
	npcBot.ShouldPush=ShouldPush;
	npcBot.IsCore=IsCore;
end

function LoadUpdates()
	local npcBot=GetBot();

	LaningState=npcBot.LaningState;
	LanePos=npcBot.LanePos;
	CurLane=npcBot.CurLane;
	MoveThreshold=npcBot.MoveThreshold;
	DamageThreshold=npcBot.DamageThreshold;
	ShouldPush=npcBot.ShouldPush;
	IsCore=npcBot.IsCore;
end

function Think()
	local npcBot=GetBot();
	Updates();
	SaveUpdates();
	
	if npcBot:IsChanneling() or npcBot:IsUsingAbility() then
		return;
	end
	
	if GetBack() and UseFarmingCombo() and UseQ() then
		--LaningState = mode_generic_laning.Thinker(LaningState,LanePos,CurLane,1.0,0.95,ShouldPush);
		mode_generic_laning.Think();
		LaningState=npcBot.LaningState;
		LoadUpdates();
	end
end

--------
