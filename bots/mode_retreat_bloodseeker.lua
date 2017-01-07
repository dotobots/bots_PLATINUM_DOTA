------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_retreat_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_retreat.OnStart();
end

function OnEnd()
	mode_generic_retreat.OnEnd();
end

function GetDesire()
	return mode_generic_retreat.GetDesire();
end

function Think()
	mode_generic_retreat.Think();
end

--------
