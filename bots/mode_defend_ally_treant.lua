------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_defend_ally_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_defend_ally.OnStart();
end

function OnEnd()
	mode_generic_defend_ally.OnEnd();
end

function GetDesire()
	return mode_generic_defend_ally.GetDesire();
end

function Think()
	mode_generic_defend_ally.Think();
end

--------
