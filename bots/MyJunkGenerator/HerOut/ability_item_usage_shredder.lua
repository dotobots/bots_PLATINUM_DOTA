
function AbilityUsageThink()
end

function CourierUsageThink()
	npcBot=GetBot();
	if (npcBot:GetStashValue()>1000 and IsCourierAvailable()) then
		npcBot:Action_CourierDeliver();
	end
end
