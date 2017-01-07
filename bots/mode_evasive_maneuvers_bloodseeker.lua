------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_evasive_maneuvers_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_evasive_maneuvers.OnStart();
end

function OnEnd()
	mode_generic_evasive_maneuvers.OnEnd();
end

function GetDesire()
	return mode_generic_evasive_maneuvers.GetDesire();
end

function Think()
	mode_generic_evasive_maneuvers.Think();
end

--------
