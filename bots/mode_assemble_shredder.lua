------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_assemble_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_assemble.OnStart();
end

function OnEnd()
	mode_generic_assemble.OnEnd();
end

function GetDesire()
	return mode_generic_assemble.GetDesire();
end

function Think()
	mode_generic_assemble.Think();
end

--------
