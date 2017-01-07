-------
------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

require( GetScriptDirectory().."/mode_defend_tower_bot_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_defend_tower_bot.OnStart();
end

function OnEnd()
	mode_generic_defend_tower_bot.OnEnd();
end

function GetDesire()
	return mode_generic_defend_tower_bot.GetDesire();
end

function Think()
	mode_generic_defend_tower_bot.Think();
end

--------
