------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_ward_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_ward.OnStart();
end

function OnEnd()
	mode_generic_ward.OnEnd();
end

function GetDesire()
	return mode_generic_ward.GetDesire();
end

function Think()
	mode_generic_ward.Think();
end

--------
