------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_roam_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

local isRoaming=false;
local Target=nil;

local Abilities ={
"bloodseeker_bloodrage",
"bloodseeker_blood_bath",
"bloodseeker_thirst",
"bloodseeker_rupture"
};


function OnStart()
	mode_generic_roam.OnStart();
end

function OnEnd()
	mode_generic_roam.OnEnd();
end

local function FindTarget()
	--npcBot:GetEstimatedDamageToTarget( true, WeakestCreep, AttackSpeed, DAMAGE_TYPE_PHYSICAL )
	local npcBot=GetBot();
	
	local mindis=100000;
	local candidate=nil;
	local MaxScore=-1;
	local ms=npcBot:GetCurrentMovementSpeed();
	
	for i=1,5,1 do
		local enemy=GetTeamMember(Utility.GetOtherTeam(),i);
		if Utility.NotNilOrDead(enemy) and enemy:GetHealth()>0 and (GetUnitToLocationDistance(enemy,Utility.Fountain(Utility.GetOtherTeam()))>4500 or (npcBot.IsJungling~=nil and (not npcBot.IsJungling))) then
			local myDamage=npcBot:GetEstimatedDamageToTarget(true,enemy,5,DAMAGE_TYPE_ALL);
		
			if myDamage>enemy:GetHealth() then
				local nfriends=0;
				for j=1,5,1 do
					local enemy2=GetTeamMember(Utility.GetOtherTeam(),j);
					if Utility.NotNilOrDead(enemy2) and enemy2:GetHealth()>0 then
						if GetUnitToUnitDistance(enemy,enemy2)<1200 and enemy2:GetHealth()/enemy2:GetMaxHealth()>0.4 then
							nfriends=nfriends+1;
						end
					end
				end
				
				local nMyFriends=0;
				for j =1,5,1 do
					local Ally=GetTeamMember(GetTeam(),j);
					if Utility.NotNilOrDead(Ally) and GetUnitToUnitDistance(enemy,Ally)<1200 then
						if Ally:GetActiveMode()==BOT_MODE_RETREAT then
							nMyFriends=nMyFriends+3;
						else
							nMyFriends=nMyFriends+1;
						end
					end
				end
				
				local score=Min(myDamage/enemy:GetHealth(),5) + (nMyFriends)/2 - (nfriends-1)/2 - GetUnitToUnitDistance(enemy,npcBot)/6000 + ms/1000;
				if score>MaxScore then
					candidate=enemy;
					MaxScore=score;
				end
			end
		end
	end
	
	return candidate,MaxScore;
end

function GetDesire()
	local npcBot=GetBot();
	if not npcBot.ShouldPush then
		return 0.0;
	end
	
	if isRoaming then
		return 0.65;
	end
	
	local ms=npcBot:GetCurrentMovementSpeed();
	local hp=npcBot:GetHealth()/npcBot:GetMaxHealth();
	
	if ms>=420 and hp>=0.75 then
		local Score=0;
		local Candidate=nil;
		
		Candidate,Score=FindTarget();

		if Candidate==nil or Score<1 then
			return 0.0;
		end
		
		Target=Candidate;
		
		isRoaming=true;
		npcBot.isRoaming=true;
		npcBot:Action_Chat("Roaming to gank",false);
		return 0.65;
	end
	
	return 0.0;
end

function Think()
	local npcBot=GetBot();
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() then
		return;
	end
	
	local Score=0;
	Target,Score=FindTarget();
	if Target==nil or npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.37  or Score < 0.5 then
		isRoaming=false;
		npcBot.isRoaming=false;
		return;
	end

	local aw=npcBot:GetAbilityByName(Abilities[2]);
	local ar=npcBot:GetAbilityByName(Abilities[4]);
	
	local dist=GetUnitToUnitDistance(Target,npcBot);
	
	if ar~=nil and ar:IsFullyCastable() and dist < ar:GetCastRange()-100 then
		npcBot:Action_UseAbilityOnEntity(ar,Target);
		return;
	end
	
	if aw~=nil and aw:IsFullyCastable() and (dist < aw:GetCastRange()) and (ar==nil or (not ar:IsFullyCastable())) then
		npcBot:Action_UseAbilityOnLocation(aw,Target:GetLocation());
		return;
	end
	
	if dist<500 then
		npcBot:Action_AttackUnit(Target,true);	
		return;
	end
	

	npcBot:Action_MoveToLocation(Target:GetLocation());

	mode_generic_roam.Think();
end

--------
