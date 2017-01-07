------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

Utility = require( GetScriptDirectory().."/Utility");

local Dur=0;
local UltTimer=-1000;
local UltDuration=12;

local Abilities ={
"bloodseeker_bloodrage",
"bloodseeker_blood_bath",
"bloodseeker_thirst",
"bloodseeker_rupture"
};

local function UseQ()
	local npcBot=GetBot();
	
	local ability=npcBot:GetAbilityByName(Abilities[1]);
	if ability:IsFullyCastable() then
		npcBot:Action_UseAbilityOnEntity(ability,npcBot);
	end
end

local function UseW()

end

local function UseUlt()

end

local TrashTalk=
{
[10]="I wanted to go mid",
[12]="this moron took my FUJKING lane",
[633]="...",
[707]="I'm real, IDK about you guys"
}

local TrashTalkHero=
{
[1]="zuus",
[3]="zuus",
[4]="zuus",
[6]="zuus",
[10]="bloodseeker",
[12]="bloodseeker",
[550]="shredder",
[633]="zuus",
[707]="shredder"
}

local function HeroIsHere(heroname)
	for i=1,5,1 do
		local Ally=GetTeamMember(GetTeam(),i);
		if Ally~=nil then
			if string.find(Ally:GetUnitName(),heroname)~=nil then
				return true;
			end
		end
	end
	
	return false;
end

local function ShitTalk()
	local npcBot=GetBot();
	
	local now = math.floor(DotaTime());
	if TrashTalk[now]~=nil and HeroIsHere(TrashTalkHero[now]) then
		npcBot:Action_Chat(TrashTalk[now],true);
		TrashTalk[now]=nil;
	end
end

function AbilityUsageThink()

	local npcBot=GetBot();

	if npcBot:IsUsingAbility() or npcBot:IsChanneling() then
		return;
	end
	
	if npcBot:GetActiveMode()==BOT_MODE_RETREAT then
		return;
	end
	
	UseUlt();
	
	if npcBot:GetActiveMode()==BOT_MODE_RETREAT and (Utility.IsItemInInventory("item_invis_sword") or Utility.IsItemInInventory("item_silver_edge")) then
		return;
	end
		
	UseQ();
	UseW();
end

function CourierUsageThink()
	ShitTalk();
	local npcBot=GetBot();
	if (npcBot:IsAlive() and (npcBot:GetStashValue()>900 or npcBot:GetCourierValue()>0 or Utility.HasRecipe()) and IsCourierAvailable()) then
		npcBot:Action_CourierDeliver();
	end
end


function ItemUsageThink()
	Utility.UseItems();
	Utility.DropJunks();
end


function BuybackUsageThink()
end
