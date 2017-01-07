------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_rune_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_rune.OnStart();
end

function OnEnd()
	mode_generic_rune.OnEnd();
end

function GetDesire()
	return mode_generic_rune.GetDesire();
end

function Think()
	mode_generic_rune.Think();
end

--------
