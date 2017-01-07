------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_roam_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_roam.OnStart();
end

function OnEnd()
	mode_generic_roam.OnEnd();
end

function GetDesire()
	return mode_generic_roam.GetDesire();
end

function Think()
	mode_generic_roam.Think();
end

--------
