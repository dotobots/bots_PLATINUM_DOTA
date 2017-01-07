------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_farm_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_farm.OnStart();
end

function OnEnd()
	mode_generic_farm.OnEnd();
end

function GetDesire()
	return mode_generic_farm.GetDesire();
end

function Think()
	mode_generic_farm.Think();
end

--------
